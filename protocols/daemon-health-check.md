---
id: daemon-health-check
type: procedure
owner: salus
created: 2026-04-03
updated: 2026-04-03
status: canonical
description: Daemon health monitoring and alerting procedure for Salus
requires: VESTA-SPEC-009 (Daemon Specification)
---

# Daemon Health Check Procedure

## Overview

Salus monitors daemon health by querying the `/api/health` endpoint and MongoDB worker state. This procedure defines the standard checks, alert thresholds, and recovery actions for dotsh daemon operations.

## 1. Health Check Interval

- **Check frequency:** Every 60 seconds
- **Timeout:** 10 seconds per check (including HTTP timeout + MongoDB query)
- **Retry on timeout:** Retry once after 5 seconds; if still timeout, mark as unhealthy

## 2. Primary Health Check: `/api/health` Endpoint

### 2.1 HTTP GET Request

```bash
endpoint="http://${DAEMON_BIND_IP}:${DAEMON_PORT}/api/health"
response=$(curl -s --max-time 10 "${endpoint}")
http_status=$?
```

**Required environment variables:**
- `DAEMON_BIND_IP` — IP address daemon is bound to (from `passenger.json` or config)
- `DAEMON_PORT` — Daemon DDP/HTTP port (default: 28282)

### 2.2 Response Parsing

The daemon returns JSON with this schema (all fields required):

```json
{
  "status": "healthy|degraded|unhealthy",
  "passengers": 8,
  "workers": {
    "total": 12,
    "healthy": 11,
    "insane": 0,
    "stale": 1
  },
  "uptime": 3600,
  "version": "1.0.0"
}
```

**Parsing steps:**
1. Verify HTTP response status is 200
2. Parse JSON response
3. Verify all required fields are present
4. Extract `status`, `workers.insane`, `workers.stale`, `uptime`

If parsing fails, record as **UNHEALTHY** (endpoint degraded or daemon not responding).

### 2.3 Status Interpretation

| Daemon Status | Salus Action | Escalation |
|---|---|---|
| `healthy` | Log: OK | None |
| `degraded` | Log: Warning (some workers failing) | Monitor next check |
| `unhealthy` | Log: Error; attempt recovery | Alert if persists > 2 checks (120 sec) |

### 2.4 Alert Conditions

**IMMEDIATE ALERT** (escalate to Juno):
- `status: "unhealthy"` (MongoDB down, daemon unreachable, or DDP server down)
- HTTP request timeout or connection refused
- JSON response missing required fields

**WARNING LOG** (monitor, escalate if persistent):
- `status: "degraded"` for > 3 consecutive checks (180 seconds)
- `workers.insane > 0` (worker has exceeded max retry attempts)
- `workers.stale > 0` (worker has not heartbeat for 5+ minutes)

## 3. Secondary Checks: MongoDB Worker State

### 3.1 MongoDB Connection Test

Verify MongoDB is reachable and contains worker documents:

```bash
# Test MongoDB connection
mongo_test=$(mongosh --eval "db.workers.countDocuments({})" 2>&1)
if [[ $? -ne 0 ]]; then
  log_error "MongoDB unreachable: ${mongo_test}"
  # Escalate as critical — daemon cannot persist worker state
fi
```

### 3.2 Worker State Queries

Run these queries to assess worker health:

```javascript
// 1. Failed workers (state: "error")
db.workers.countDocuments({ state: "error" })

// 2. Insane workers (exceeded max retries)
db.workers.countDocuments({ insane: true })

// 3. Stale workers (no heartbeat for 5+ minutes)
db.workers.countDocuments({
  lastHeartbeat: { $lt: new Date(Date.now() - 5*60*1000) }
})

// 4. Worker success rate (by service)
db.workers.aggregate([
  { $group: {
      _id: "$service",
      successCount: { $sum: "$successCount" },
      errorCount: { $sum: "$errorCount" },
      healthyWorkers: { $sum: { $cond: [{ $eq: ["$state", "running"] }, 1, 0] } }
    }
  }
])

// 5. Last heartbeat timestamp (indicates daemon freshness)
db.workers.findOne({}, { sort: { lastHeartbeat: -1 } })
```

### 3.3 Worker Health Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| Insane workers | > 0 | > 3 |
| Stale workers | > 1 | > 5 |
| Failed workers | > 2 | > 5 |
| Overall error rate | > 5% | > 20% |

## 4. Daemon Restart Detection

Track daemon uptime to detect unexpected restarts:

```bash
# Store previous uptime
prev_uptime=${LAST_DAEMON_UPTIME:-0}
current_uptime=$(echo "${response}" | jq '.uptime')

# If current < previous, daemon was restarted
if (( current_uptime < prev_uptime - 30 )); then
  log_warn "Daemon restart detected (uptime: ${prev_uptime}s -> ${current_uptime}s)"
  LAST_RESTART=$(date +%s)
fi

# Update for next check
LAST_DAEMON_UPTIME=${current_uptime}
```

**Alert if daemon restarts > 3 times per hour** (indicates instability).

## 5. Health Check Script Template

```bash
#!/bin/bash
# ~/.salus/scripts/check-daemon-health.sh
# Called every 60 seconds by Salus healing protocol

set -u
source ~/.koad-io/.env
source ~/.salus/.env

DAEMON_BIND_IP="${KOAD_IO_BIND_IP:-127.0.0.1}"
DAEMON_PORT="${DAEMON_PORT:-28282}"
ENDPOINT="http://${DAEMON_BIND_IP}:${DAEMON_PORT}/api/health"
STATE_FILE="${ENTITY_DIR}/.daemon-health-state"

# Initialize state file
if [[ ! -f "${STATE_FILE}" ]]; then
  cat > "${STATE_FILE}" << EOF
last_check=$(date +%s)
status=unknown
unhealthy_count=0
restart_count=0
last_uptime=0
EOF
fi

# Load previous state
source "${STATE_FILE}"

# Check daemon health endpoint
response=$(curl -s --max-time 10 "${ENDPOINT}" 2>&1)
http_code=$?

if [[ ${http_code} -ne 0 ]]; then
  echo "UNHEALTHY: Connection failed (curl exit ${http_code})" >&2
  unhealthy_count=$((unhealthy_count + 1))
  status="unreachable"
else
  # Parse response
  status=$(echo "${response}" | jq -r '.status // "error"')
  workers_insane=$(echo "${response}" | jq '.workers.insane // -1')
  workers_stale=$(echo "${response}" | jq '.workers.stale // -1')
  uptime=$(echo "${response}" | jq '.uptime // -1')
  
  if [[ -z "${status}" ]]; then
    echo "UNHEALTHY: Invalid JSON response" >&2
    status="invalid"
    unhealthy_count=$((unhealthy_count + 1))
  else
    # Check status
    case "${status}" in
      healthy)
        echo "OK: Daemon healthy (workers: ${workers_insane} insane, ${workers_stale} stale, uptime: ${uptime}s)"
        unhealthy_count=0
        ;;
      degraded)
        echo "WARNING: Daemon degraded (workers: ${workers_insane} insane, ${workers_stale} stale)"
        ;;
      unhealthy)
        echo "ERROR: Daemon unhealthy" >&2
        unhealthy_count=$((unhealthy_count + 1))
        ;;
    esac
    
    # Detect restart
    if (( uptime < last_uptime - 30 )); then
      restart_count=$((restart_count + 1))
      echo "WARNING: Daemon restart detected (restart #${restart_count})" >&2
    fi
    last_uptime=${uptime}
  fi
fi

# Save state
cat > "${STATE_FILE}" << EOF
last_check=$(date +%s)
status=${status}
unhealthy_count=${unhealthy_count}
restart_count=${restart_count}
last_uptime=${last_uptime}
EOF

# Alert escalation
if (( unhealthy_count >= 2 )); then
  echo "ALERT: Daemon unhealthy for ${unhealthy_count} checks, escalating to Juno" >&2
  # File GitHub issue on koad/juno
fi

if (( restart_count >= 3 )); then
  echo "ALERT: Daemon restarted ${restart_count} times/hour, investigating" >&2
fi

exit 0
```

## 6. MongoDB Worker State Query (Secondary Check)

Optional secondary check for detailed worker diagnostics:

```bash
#!/bin/bash
# ~/.salus/scripts/check-workers-state.sh
# Run every 5 minutes for detailed diagnosis

source ~/.salus/.env

# Count workers by state
error_workers=$(mongosh --quiet --eval "db.workers.countDocuments({state: 'error'})")
insane_workers=$(mongosh --quiet --eval "db.workers.countDocuments({insane: true})")
stale_workers=$(mongosh --quiet --eval "db.workers.countDocuments({lastHeartbeat: {'\$lt': new Date(Date.now() - 5*60*1000)}})")

echo "Workers - error: ${error_workers}, insane: ${insane_workers}, stale: ${stale_workers}"

# Alert on critical thresholds
if (( insane_workers > 3 )); then
  echo "CRITICAL: ${insane_workers} insane workers" >&2
fi

if (( stale_workers > 5 )); then
  echo "WARNING: ${stale_workers} stale workers" >&2
fi
```

## 7. Reporting

### 7.1 Daily Report

Include daemon health in daily Salus report (`~/.salus/reports/YYYY-MM-DD.md`):

```markdown
## Daemon Health

- **Status:** healthy | degraded | unhealthy
- **Uptime:** NNNN seconds
- **Workers:** N healthy, N insane, N stale
- **Restarts:** N times today
- **Alerts:** (list any escalated alerts)
```

### 7.2 Escalation to Juno

File GitHub issue on `koad/juno` if:
- Daemon unhealthy > 180 seconds
- Daemon restarted > 3 times per hour
- MongoDB connectivity lost
- Worker error rate > 20%

**Issue format:**
```
Title: Daemon unhealthy — [status] [reason]
Body:
- Status: unhealthy
- Last error: [from /api/health]
- Workers: N insane, N stale, N error
- Recommendation: [check MongoDB | restart daemon | investigate worker XYZ]
```

## 8. Implementation Notes

### Environment Variables Required

- `KOAD_IO_BIND_IP` — From framework layer (default: 127.0.0.1)
- `DAEMON_PORT` — From daemon config (default: 28282)
- `ENTITY_DIR` — From entity layer (Salus's home directory)

### Cron Integration

Add to Salus crontab via systemd timer or cron:

```bash
# Check daemon health every 60 seconds
* * * * * /bin/bash -c 'source ~/.koad-io/.env && source ~/.salus/.env && /home/koad/.salus/scripts/check-daemon-health.sh'
```

### Dependencies

- `curl` — HTTP requests
- `jq` — JSON parsing
- `mongosh` — MongoDB queries (optional, for secondary check)
- `bash` 4.0+

### Error Handling

- Network timeout: Retry once, then mark unhealthy
- JSON parse error: Mark as invalid response
- Missing fields: Mark endpoint as degraded
- MongoDB unreachable: Mark as critical (daemon cannot persist state)

## 9. Recovery Actions

### Unhealthy Status Triggers Investigation

1. Check daemon process is running: `ps aux | grep 'daemon'`
2. Check MongoDB is reachable: `mongosh --eval "db.version()"`
3. Check DDP port is open: `netstat -tlnp | grep :28282`
4. Check daemon logs: `journalctl -u koad-daemon -n 50`
5. If all appear normal, request manual daemon restart from Juno

### Degraded Status Triggers Monitoring

- Log individual stale/insane workers
- Query MongoDB for worker details and recent errors
- If condition persists > 3 checks, escalate to UNHEALTHY level
- Recommend worker restart or deadline extension to entity owner

---

**Related Specs:**
- VESTA-SPEC-009 — Daemon Specification (health model, `/api/health` schema)
- VESTA-SPEC-005 — Cascade Environment (daemon env vars)

**Last Updated:** 2026-04-03

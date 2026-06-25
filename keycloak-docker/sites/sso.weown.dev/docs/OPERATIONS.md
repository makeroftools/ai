# SSO Operations Runbook — sso.weown.id

> **Part of PRJ-003 — KeyCloak SSO Deployment**
> **Source:** `keycloak-docker/sites/sso.weown.dev/docs/OPERATIONS.md`
> **Deployed:** `/opt/sso/` (droplet)
> **CCC-ID:** MOT_2026-W26_3012

---

## 1. Admin Access

| Tier | Source | IP | Method |
|:----:|:-------|:--:|:-------|
| 🔵 **Primary** | ProtonVPN dedicated server | `79.127.183.180` | OpenVPN → Browser |
| 🟡 **Break-glass** | Decent.House #NoDe (North Denver) | `66.33.8.133` | Direct connection (T-Mobile Fiber) |
| 🔴 **Nuclear** | Minimus.io droplet console | N/A | Web dashboard → terminal (last resort) |

## 2. Break-Glass Procedure

Follow this escalation path when primary admin access is unavailable.

### Step 1 — Verify Primary

```bash
# Test connectivity to ProtonVPN IP
ping -c 3 79.127.183.180

# Check Caddy ACL status (from droplet)
ssh root@sso-droplet 'docker exec sso-caddy-1 caddy validate --config /etc/caddy/Caddyfile'
```

If primary is down → **Step 2**.

### Step 2 — Break-Glass (Decent.House #NoDe)

- If @GTM 🎯 is at #NoDe, IP `66.33.8.133` is already whitelisted in Caddy ACL.
- If remote access to #NoDe is available, route through `66.33.8.133`.
- **Verify access:** `curl -s -o /dev/null -w "%{http_code}" https://sso.weown.id/admin/`
- Expected: `403` (if not on whitelist) or `200` (if connected from whitelisted IP).

If break-glass is unreachable → **Step 3**.

### Step 3 — Nuclear (Minimus.io Console)

1. Log into **Minimus.io** dashboard.
2. Navigate to **Droplets** → select `sso` droplet.
3. Open **Console Access** (web-based terminal).
4. Authenticate as `root`.
5. **Temporarily allow your IP:**

   ```bash
   YOUR_IP="$(curl -s4 https://ifconfig.me)"
   sed -i "s/not remote_ip 79.127.183.180/not remote_ip 79.127.183.180\n        not remote_ip $YOUR_IP/" /opt/sso/Caddyfile
   docker exec sso-caddy-1 caddy validate --config /etc/caddy/Caddyfile
   docker exec sso-caddy-1 caddy reload --config /etc/caddy/Caddyfile
   ```

6. **Notify team** — send a ContextVolley with your temporary IP and reason.
7. **Revert within 24 hours** — edit `/opt/sso/Caddyfile`, remove temporary IP, run `caddy reload`.
8. **Log the event** — update CV chain with incident CCC-ID.

## 3. ACL Source & Deployment

| Item | Path |
|:-----|:-----|
| **Source Caddyfile** | `docker/Caddyfile` (config repo) |
| **Deployed Caddyfile** | `/opt/sso/Caddyfile` (droplet) |
| **Compose file** | `/opt/sso/compose.yaml` |

### Deploy Caddyfile Change

```bash
# Option A: Full ansible deploy (bounces stack)
INFISICAL_PROJECT_ID=117b72e5-c084-44f6-9393-f5252b5ae0a8 \
  ./scripts/deploy.sh root@<droplet-ip>

# Option B: Surgical SCP + reload (zero-downtime)
scp docker/Caddyfile root@<droplet-ip>:/opt/sso/Caddyfile
ssh root@<droplet-ip> 'docker exec sso-caddy-1 caddy reload --config /etc/caddy/Caddyfile'
```

## 4. Verification

After any ACL change, verify:

```bash
# Public should get 403
curl -s -o /dev/null -w "Public /admin/: HTTP %{http_code}\n" https://sso.weown.id/admin/

# Realms endpoint should remain public
curl -s -o /dev/null -w "Public /realms/master: HTTP %{http_code}\n" https://sso.weown.id/realms/master

# Health should be accessible
curl -s -o /dev/null -w "Health: HTTP %{http_code}\n" https://sso.weown.id/health/ready
```

## 5. Version History

| Version | Date | Author | Changes |
|:-------:|:----:|:-------|:--------|
| v1 | 2026-06-24 | @MOT 🛠️ | Initial — break-glass SOP, ACL reference, nuclear procedure |

# CHAIN: CV-keycloak-admin-lockdown-2026-W26

# Topic: KeyCloak Admin Static IP Lockdown (ProtonVPN BusinessVPN)

# Opened: 2026-06-24

# Status: ✅ FINAL — devTEST PASSED from ProtonVPN by @GTM, handed off to @CTO for R-011 human approval

# Incoming REF: GTM_2026-W26_3013

| Link | CCC-ID | Direction | Date | Status | Summary |
|:----:|:-------|:----------|:-----|:-------|:--------|
| ← IN | GTM_2026-W26_3005 | ← IN | 2026-06-24 | ✅ RCVD | @GTM requests admin panel locked to ProtonVPN static IP `79.127.183.180` |
| CV-1 | ❌ SKIPPED | — | — | ❌ SKIP | Procedural error: went straight to full response without grounding CV-2 as separate investigate step |
| CV-2 | MOT_2026-W26_3001 | → OUT | 2026-06-24 | ✅ SENT | Investigation — reviewed Caddyfile, DO firewall, terraform, compose; designed Caddy-level ACL |
| CV-3 | MOT_2026-W26_3001 | → OUT | 2026-06-24 | ✅ SENT | RESPOND — Findings + proposed solution sent to @GTM (same CCC-ID as CV-2 since they were combined) |
| ← IN | GTM_2026-W26_3013 | ← IN | 2026-06-24 | ✅ RCVD | R-011 GRANTED — explicit approval from @GTM, full deployment checklist provided |
| CV-4 | MOT_2026-W26_3004 | → OUT | 2026-06-24 | ✅ RCVD | Acknowledgment — R-011 received, ready to deploy Caddyfile change |
| CV-5 | MOT_2026-W26_3005 | → OUT | 2026-06-24 | ✅ DONE | DEPLOY — Caddy ACL implemented, zero-downtime reload, all 3 paths verified |
| CV-6 | MOT_2026-W26_3007 | → OUT | 2026-06-24 | ✅ SENT | CONFIRM — CV-6 confirmation volley sent to @GTM, chain closed |
| ← IN | GTM_2026-W26_3035 | ← IN | 2026-06-24 | ✅ RCVD | @GTM devTEST: ACL 403 from public ✅ — Admin returns 'Page not found' from ProtonVPN ❌ — Plus Cloudflare migration discussion |
| CV-7 | MOT_2026-W26_3010 | → OUT | 2026-06-24 | ✅ SENT TO @GTM | BUGFIX — CV-7 volley sent to @GTM: root cause analysis (Host header + KC26 path), both fixed, zero-downtime, 9/9 tests |
| ← IN | GTM_2026-W26_3038 | ← IN | 2026-06-24 | ✅ RCVD | @GTM devTEST SUCCESSFUL — admin console loads from ProtonVPN ✅, public 403 confirmed. Moving to @CTO for R-011 human approval on PRJ-003 |
| ← IN | CTO_2026-W26_3011 | ← IN | 2026-06-24 | ✅ RCVD | @CTO devTEST acknowledged. Preconditions: walkthrough + break-glass gap documented. Positioned READY-TO-GRANT. Identified single-IP SPOF |
| CV-8 | MOT_2026-W26_3011 | → OUT | 2026-06-24 | ✅ SENT TO @CTO + @GTM | RESPOND — Break-glass analysis: Option A (add @SHD IP as secondary) + Option C (Minimus.io console SOP) recommended. DOC ops runbook created. Unblocks @CTO R-011 |
| ← IN | GTM_2026-W26_3041 | ← IN | 2026-06-24 | ✅ RCVD | @GTM answer: break-glass IP = 66.33.8.133 (Decent.House #NoDe). Caddy ACL update + TSD-403 doc requested. Async walkthrough this week. |
| CV-9 | MOT_2026-W26_3013 | → OUT | 2026-06-24 | ✅ SENT TO @CTO + @GTM | CONFIRM — Option A deployed (66.33.8.133 whitelisted), OPERATIONS.md runbook live, zero-downtime reload, 3/3 tests passing. All R-011 preconditions met. |

## Artifacts

| File | Description |
|:-----|:------------|
| `inbox/2026-06-24_GTM_Keycloak-Admin-Static-IP-Lockdown.md` | Raw incoming CV from @GTM |
| `../2026-06-24_Keycloak-Admin-Static-IP-Lockdown.md` | MOT RESPOND volley — investigation + proposal |
| `../../../../keycloak-docker/sites/sso.weown.dev/docker/Caddyfile` | Source Caddyfile updated with admin ACL |
| `../2026-06-24_Keycloak-Admin-Lockdown-CV6-CONFIRM.md` | CV-6 CONFIRM volley — deployment summary sent to @GTM |
| `../2026-06-24_Keycloak-Admin-Lockdown-CV8-BREAK-GLASS.md` | CV-8 RESPOND volley — break-glass analysis, Option A+C recommendation, path to unblock @CTO R-011 |
| `../2026-06-24_Keycloak-Admin-Lockdown-CV9-CONFIRM.md` | CV-9 CONFIRM volley — Option A deployed, OPERATIONS.md live, all preconditions met, R-011 path clear |
| `../../../../keycloak-docker/sites/sso.weown.dev/docs/OPERATIONS.md` | SSO Operations Runbook — break-glass SOP, ACL reference, 3-tier escalation |
| `../../../../keycloak-docker/sites/sso.weown.dev/docker/compose.prod.yaml` | Docker Compose — Keycloak 26+ config, KC_HOSTNAME, KC_PROXY_HEADERS |

## Lessons Learned

### 🔴 Critical — Prevent Recurrence

1. **Pin container versions. Never use `:latest` in production.**
   The Keycloak image was `reg.mini.dev/keycloak:latest`. Between deployments, the upstream tag
   advanced from KC25 to KC26 — which **removed the `/auth` prefix** with no migration notice.
   This caused Bug #2 (ACL path matcher matched `/auth/admin/*` — a path that didn't exist).
   **Fix:** Pin the minor version in `compose.prod.yaml` and ansible vars (e.g. `:26.0`).
   Upgrades become intentional, gated by testing, not silent surprises.

2. **Test the full request path end-to-end before declaring deploy done.**
   The initial CV-6 deployment tested Caddy's response and Keycloak's response separately,
   but never tested **through Caddy into Keycloak**. Bug #1 (Host header rewrite by Caddy)
   was invisible until @GTM tested from ProtonVPN because no test sent a request through
   the complete chain. **Fix:** Every deploy must include a test from inside the docker network
   that verifies the full path: `docker exec sso-caddy-1 curl -sk https://sso.weown.id/admin/`.

3. **Create the operations runbook before or with the deploy — never as a fast-follow.**
   The SSO service had no OPERATIONS.md until CV-8/CV-9, six deployments in. All knowledge
   was in @MOT's head or scattered across 9 ContextVolleys. If someone else needed to
   diagnose admin access or perform a reload, they'd have no single source of truth.
   **Fix:** Every site template must include a `docs/OPERATIONS.md` with admin access,
   break-glass procedure, deploy commands, and verification steps — reviewed and committed
   before or coincident with the first production deploy.

4. **Verify the actual version of upstream software before writing config against it.**
   We assumed the Caddy ACL path `/auth/admin/*` was correct because older Keycloak docs
   use `/auth`. We never checked what version was actually running.
   **Fix:** Before any config work, verify actual versions:

   ```bash
   docker inspect reg.mini.dev/keycloak:latest | jq '.[].Config.Labels'
   # or
   curl -sk https://sso.weown.id/realms/master | jq '.keycloakVersion // "unknown"'
   ```

### 🟡 Important — Process & Infrastructure Improvements

5. **Automate SSH access to avoid firewall whitelist churn.**
   Every SSH session required: (a) add temp IP to `sso-fw`, (b) work, (c) remove IP.
   Three times this session. Forgot once (had to clean up).
   **Fix:** Use `doctl compute ssh` which goes through the DO control plane and bypasses
   the firewall entirely. Or add a permanent dev SSH IP. Either removes a manual step
   that's prone to error and security drift.

6. **CV-1 protocol gap — resolved.** Going forward, every incoming CV triggers
   CV-1 (acknowledge) → CV-2 (investigate) → CV-3 (respond) consistently.
   Never skip to full response without separate investigation.

### 🟢 Technical — Specific to Keycloak/Caddy

7. **Caddy v2 silently rewrites Host header** on upstream requests. This breaks
   `KC_HOSTNAME_STRICT=true`. Always add `header_up Host "{host}"` to reverse_proxy
   blocks when proxying to Keycloak (or any app that validates Host).

8. **Keycloak 26+ removed the `/auth` prefix.** Never use `/auth/` in Caddy path matchers
   or external references for KC26. Admin is at `/admin/*`, realms at `/realms/*`.

9. **Always verify ACL path matchers against real application routes.**
   The old ACL matched `/auth/admin/*` — a path that doesn't exist in KC26 — making
   the entire ACL a no-op. `/admin/*` was wide open to the public.

10. **Single-IP admin ingress is a SPOF.** Always document a break-glass path before
    production sign-off. Three-tier escalation (primary IP → secondary IP → console)
    is the recommended pattern. See `docs/OPERATIONS.md` for the implementation.

### 🔧 Tooling Checklist — Applied to This Deploy (Fast-Follow Items)

| Item | Status | Detail |
|:-----|:------:|:-------|
| Version pin Keycloak image | ✅ DONE | `compose.prod.yaml` pinned to `:26.0`. `ansible/deploy.yml` vars pinned to `:26.0`. |
| Pre-deploy version check in deploy script | ✅ DONE | Ansible pre-task: compares running container tag vs pinned version, warns on mismatch. |
| Full-path test in deployment verification | ✅ DONE | Smoke test check 3.6: tests Caddy → Keycloak from inside docker network, catches Host header bugs. |
| SSH access automation | ✅ DONE | `./site.sh ssh` — uses `doctl compute ssh` bypassing firewall, no temp IP whitelist needed. |
| Runbook completeness check in ISC template | ✅ DONE | TMPL-010 ISC now has Check 9: OPERATIONS.md runbook presence for infrastructure instances. |

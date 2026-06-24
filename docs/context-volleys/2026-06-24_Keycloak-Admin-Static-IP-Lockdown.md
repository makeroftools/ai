═══════════════════════════════════════════════════════════════════════════════
[REF: MOT_2026-W26_3001] | 📢 #ContextVolley:AI:@MOT → @GTM 🎯 🛠️ — KeyCloak Admin Static IP Lockdown

FROM: AI:@MOT 🛠️ @ INT-P08:CCC (u-mot_user)
TO: **@GTM 🎯** (yonks｜🤖🏛️🪙｜Jason Younker ♾️) @ INT-B001:CCC
CC: **@GTM 🎯**, @SHD 🇵🇰, #MetaCouncil
RE: **KeyCloak Admin Panel — ProtonVPN Static IP Lockdown — Investigation & Proposed Solution**

---

### HWM GROUNDING

- **0. R-194 AUTHORITY CHECK:** ✅ REFERENCE — GTM_2026-W26_3005, direct response to @GTM request
- **1. ANCHOR CCC-ID:** MOT_2026-W26_3001
- **2. SOURCE:** @GTM 🎯 — Request to lock down admin panel to ProtonVPN Dedicated Server IP `79.127.183.180`

---

## 📢 #ContextVolley: KEYCLOAK ADMIN LOCKDOWN — INVESTIGATION & PROPOSED SOLUTION

### 🎯 Response to @GTM 🎯 — Q1-Q5 Answered

| # | Question | Answer |
|:-:|:---------|:-------|
| **1** | **Reverse proxy layer?** | **Caddy** — running as a Docker container (`reg.mini.dev/caddy:2`) alongside Keycloak. Caddyfile at `/opt/sso/Caddyfile` on droplet, source in [`keycloak-docker/sites/sso.weown.dev/docker/Caddyfile`](https://github.com/WeOwnNetwork/ai/tree/main/keycloak-docker/sites/sso.weown.dev/docker/Caddyfile). No Nginx, no Cloudflare Tunnel. |
| **2** | **Existing firewall rules?** | **DigitalOcean Cloud Firewall** (`sso-fw`) — restricts SSH (22) to two ops IPs, leaves HTTP/80 and HTTPS/443 wide open (`0.0.0.0/0`). **No UFW/iptables on the host** — no application-layer IP filtering exists today. |
| **3** | **API vs UI separation?** | **Same path.** Keycloak serves admin UI + admin REST API + user-facing SSO all on `sso.weown.id`. Admin under `/auth/admin/*`, public SSO under `/auth/realms/*`. `KC_HOSTNAME_ADMIN_URL` is set to `https://sso.weown.id` (no separate subdomain). **Caddy can filter by path** — no Keycloak config change needed. |
| **4** | **Other services on same host?** | **No.** The `sso` droplet is dedicated — only three containers: Keycloak, PostgreSQL 16, Caddy. No shared infrastructure. |
| **5** | **Current admin access patterns?** | **Fully public today.** Admin panel at `sso.weown.id/auth/admin/` has zero IP restriction. No agents, MAITs, or services hit the admin API from outside — only human operators via browser. The `admin.sso.weown.id` subdomain (in Caddyfile) proxies to the same container. |

---

## 🏛️ Proposed Solution — Caddy-Level Path-Based ACL

**No infrastructure changes. No droplet rebuild. No Ansible re-run. Two commands, ~10 seconds, zero downtime.**

### Updated Caddyfile

```caddy
sso.weown.id {
    # ─── Admin panel — VPN-only (ProtonVPN BusinessVPN Dedicated Server) ──
    @admin {
        path /auth/admin/*
    }
    handle @admin {
        @vpn {
            remote_ip 79.127.183.180
        }
        handle @vpn {
            reverse_proxy keycloak:8080 {
                flush_interval -1
                header_up Forwarded "proto=https;host={host}"
            }
        }
        handle {
            respond "Access Denied — Admin panel requires ProtonVPN.\nConnect to ♾️ WeOwnNet 🌐 BusinessVPN and retry." 403 {
                header Content-Type "text/plain; charset=utf-8"
            }
        }
    }

    # ─── Public SSO — accessible to all ──
    handle {
        reverse_proxy keycloak:8080 {
            flush_interval -1
            header_up Forwarded "proto=https;host={host}"
        }
    }

    log {
        output file /var/log/caddy/sso.log
    }
}

# Admin subdomain — VPN-only (redundant protection layer)
admin.sso.weown.id {
    @vpn {
        remote_ip 79.127.183.180
    }
    handle @vpn {
        reverse_proxy keycloak:8080 {
            flush_interval -1
            header_up Forwarded "proto=https;host={host}"
        }
    }
    handle {
        respond "Access Denied — Admin panel requires ProtonVPN." 403
    }
}
```

### Architecture — With #BetterUnderstanding

```text
    🌐 PUBLIC INTERNET
         │
         ├── 🔒 sso.weown.id/auth/admin/*
         │     → Caddy checks remote_addr
         │     → allow: 79.127.183.180     (ProtonVPN BusinessVPN — STATIC ✅)
         │     → deny:  all                 (403 with clear message)
         │
         ├── ✅ sso.weown.id/auth/realms/* (and everything else)
         │     → PUBLIC — required for authentication flow
         │     → proxied to keycloak:8080 as-is
         │
         ├── ✅ sso.weown.id ports 80/443
         │     → PUBLIC — ACME challenges + HTTPS traffic
         │
         └── 🔐 ProtonVPN BusinessVPN
               → Dedicated Server: 79.127.183.180
               → All admins connect here FIRST
               → Then access Keycloak admin panel
               → Only way in. No exceptions.
```

---

## 🛡️ Optional Complementary Hardening (Flagged, Not in Scope)

| Hardening | Effort | Notes |
|:----------|:-------|:------|
| **Rate limiting on admin path** | +2 Caddyfile lines | Prevents brute force even from VPN IP |
| **Keycloak admin session TTL** | Realm setting in GUI | 15-min admin session timeout |
| **Fail2ban on 403 logs** | Install + config on host | Auto-block repeat offenders hitting the admin path |
| **MFA on admin accounts** | Keycloak OTP policy | Second factor even behind VPN |

---

### ⏱️ Response Requested

- **Acknowledge:** ✅
- **Feasibility:** ✅
- **Current reverse proxy:** Caddy
- **Timeline:** ~2 minutes after approval
- **Blockers:** None — Caddy hot-reload, zero downtime

═══════════════════════════════════════════════════════════════════════════════

| Layer | Status |
|:------|:-------|
| **IP Confirmed Static** | ✅ `79.127.183.180` — BusinessVPN Dedicated Server per @GTM |
| **Reverse Proxy** | ✅ Caddy — path-based ACL is native, zero-downtime reload |
| **Infrastructure Change Required** | ✅ **None** — Caddyfile edit + reload only |
| **No other services to impact** | ✅ Dedicated droplet, admin path only |
| **Existing firewall adequate** | ✅ DO cloud firewall + Caddy ACL = defense-in-depth |
| **admin.sso.weown.id** | ⏳ Caddyfile includes it as redundant layer — @GTM to confirm DNS needed |
| **Confirm and deploy?** | ⏳ **Awaiting @GTM 🎯 approval** |

# FlowsBros #FedArch #WeOwnSeason004 #KeyCloak #Security #ProtonVPN #StaticIP #BusinessVPN #DedicatedServer #ZeroTrust #ContextVolley

♾️ WeOwnNet 🌐 — Static IP confirmed. Caddy ACL ready. Awaiting your nod, then it's live in 2 minutes. 🫡

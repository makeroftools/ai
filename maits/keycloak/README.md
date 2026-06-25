# MAIT:Keycloak

| Field | Value |
|-------|-------|
| **ShortCode** | @MAIT:#Keycloak |
| **SME** | Keycloak — Identity & Access Management |
| **Steward** | @MOT 🛠️ |
| **Status** | 🟡 Prototype |
| **ALLM Thread** | ⏳ PENDING |
| **Instance** | INT-P01 (AI.WeOwn.Agency) |

## About

@MAIT:#Keycloak is the subject matter expert for Keycloak within the WeOwn
ecosystem. Keycloak is our SSO/IAM platform, deployed via Docker Compose with
Caddy reverse proxy, PostgreSQL storage, and administrative ACL hardening.

This MAIT covers deployment architecture, realm/user management, SSO client
configuration, admin access control, credential recovery, smoke testing, and
version management.

## Current State

- **Deployed:** ✅ WeOwn realm active with team users (mot, gtm, lfg)
- **Admin ACL:** ✅ Caddy path restriction active — admin ingress limited to
  VPN IP with break-glass secondary (details in internal runbook)
- **Smoke Test:** ✅ 18/18 checks passing
- **Version:** 🎯 Pinned at `:26.0`
- **SSO Clients:** ⏸️ BLOCKED pending R-011 (CTO architecture walkthrough)

## Related Resources

- [AGENTS.md](AGENTS.md) — Agent instructions (override file)
- [SYSTEM_PROMPT.md](SYSTEM_PROMPT.md) — Thread system prompt
- [Deployment](../../keycloak-docker/) — Infrastructure code

## Changelog

| Date | Change | By |
|------|--------|----|
| 2026-06-25 | Created — initial MAIT prototype | @MOT 🛠️ |
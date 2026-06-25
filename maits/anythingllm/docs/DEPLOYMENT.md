# Deployment — MAIT:#AnythingLLM

> #WeOwnVer: v0.1.0 · Status: 🟡 Prototype · Scope: reference for RAG ingestion

Two deployment paths exist: **Docker Compose** (preferred for new instances) and
**Kubernetes Helm** (legacy, being retired). The Docker Compose path is the active
infrastructure standard.

---

## Docker Compose Path (`anythingllm-docker/`)

The canonical deployment pattern for single-node production. Uses a Copier template
to generate per-site deployment directories under `sites/<domain>/`.

### Base Architecture

```text
┌──────────────────────────────────────────────────────────┐
│                 DigitalOcean Droplet                      │
│  ┌──────────────┐  ┌──────────────────────────────────┐  │
│  │    Caddy      │  │         AnythingLLM              │  │
│  │  (Reverse     │  │      (AI Assistant)              │  │
│  │   Proxy)      │  │                                  │  │
│  │  :80, :443    │  │  · RAG document ingestion        │  │
│  │               │  │  · OpenRouter LLM integration    │  │
│  │               │  │  · LanceDB vector storage        │  │
│  │               │  │  · Multi-workspace support       │  │
│  └──────┬───────┘  └──────────────────────────────────┘  │
│         │                                                  │
│         └──────────────────────────────────────────────────┘
│                      anythingllmnet                        │
└──────────────────────────────────────────────────────────┘
```

### Key Infrastructure Components

| Component | Role | Details |
|-----------|------|---------|
| **Caddy** | Reverse proxy | Automatic TLS via Let's Encrypt, HTTP/3, security headers. App port bound to 127.0.0.1 — only Caddy is internet-facing. |
| **AnythingLLM** | AI platform | Container runs on port 3001, accessed through Caddy. Manages workspaces, RAG, LLM calls. |
| **LanceDB** | Vector store | Embedded in-process — zero-config, no separate container. |
| **Infisical** | Secrets management | Two-project model: operator project (`weown-tofu`) for infra creds, per-site project for app secrets. |

### Provisioning Flow

1. **Render site** via Copier: `copier copy . sites/<domain> --data project_name=<slug> --data domain=<domain> --defaults --trust`
2. **Push secrets** to the site's Infisical project (`JWT_SECRET`, `OPENROUTER_API_KEY`, `ANYTHINGLLM_IMAGE`, `ADMIN_EMAIL`, `SPACES_ACCESS_KEY`, `SPACES_SECRET_KEY`)
3. **Provision** with `terraform/itofu.sh` (runs OpenTofu under `infisical run` — no `.tfvars` on disk)
4. **Deploy** with `./site.sh deploy` (auto-detects droplet IP from Terraform output)

### Infisical Security Model (ADR-006)

```text
weown-tofu (operator project)          site app project (per deployment)
  └─ TF_VAR_* infra creds                └─ OPENROUTER_API_KEY, JWT_SECRET,
       │  injected by itofu.sh                ANYTHINGLLM_IMAGE, ADMIN_EMAIL, …
       ▼                                           │ read at runtime by the
   tofu provisions the droplet                      ▼ droplet's Machine Identity
                                       Container entrypoint: `infisical run`
                                                     │
                                                     ▼
                                             Container environment
                                             (secrets in RAM only,
                                              fetched in-process)
```

- Zero application secrets on disk — only Machine Identity reaches the node
- `docker restart` re-fetches secrets from Infisical (bounce-to-refresh)
- Container image ref (`ANYTHINGLLM_IMAGE`) injected at runtime, not in git

### Backup Strategy

Daily volume backups to DO Spaces with grandfather-father-son retention (daily 30d,
monthly 12mo, yearly forever). Run via cron + `infisical run` for credential access.

### Required App Secrets (Infisical)

| Secret | Purpose |
|--------|---------|
| `JWT_SECRET` | Session signing — `openssl rand -hex 32` |
| `OPENROUTER_API_KEY` | LLM provider key |
| `ANYTHINGLLM_IMAGE` | Container image reference |
| `ADMIN_EMAIL` | Notification email |
| `SPACES_ACCESS_KEY` / `SPACES_SECRET_KEY` | DO Spaces backup credentials |

### Firewall Rules

- 22 (SSH), 80 (HTTP/ACME), 443 (HTTPS/QUIC) — only ports open
- Static reserved IP via Terraform
- Automatic security updates via `unattended-upgrades`

---

## Kubernetes Path (`anythingllm/`) — Legacy

The original deployment path using Helm charts. Being retired per ADR-005 (INT-P01
migrating from DOKS to Docker Compose).

### Helm Chart Components

| Component | Details |
|-----------|---------|
| **Deployment** | Single replica, Recreate strategy. Pod security: restricted profile, read-only root fs (with temp dirs), seccomp RuntimeDefault, Argon2id password hashing. |
| **Ingress** | nginx ingress controller with Let's Encrypt TLS, TLSv1.3 only, rate limiting (100 req/min), proxy body 100m. |
| **NetworkPolicy** | Zero-trust egress restrictions, auto-fix for ingress-nginx namespace. |
| **Backup** | CronJob daily at 2 AM UTC, 30-day retention, 10Gi PVC. |
| **Infisical** | Optional Infisical Kubernetes Operator integration for automated secret sync (60s resync, auto-reload pods). |

### K8s Helm Configuration Standards

- **Namespace:** `anything-llm`
- **Storage:** 20Gi `do-block-storage` PVC, ReadWriteOnce
- **Resources:** limits 1000m CPU / 1.5Gi memory, requests 200m CPU / 512Mi memory
- **Health checks:** Liveness `/api/ping` (120s initial delay, 5 failures tolerated), Readiness (60s delay)

### Migration Path

The `migrate-from-doks.sh` script exports data from the K8s pod (tar of
`/app/server/storage`), transfer to new droplet, restore into Docker volume,
then migrate secrets to Infisical. See `sites/ai.weown.agency/MIGRATION_RUNBOOK.md`.

---

## Known Limitations

- **No OIDC/SSO:** AnythingLLM does not natively support OIDC/OAuth2 login. Token
  hand-off or reverse-proxy auth needed for Keycloak integration.
- **Single container:** No native horizontal scaling — LanceDB is embedded and
  in-memory, limiting multi-replica deployment.
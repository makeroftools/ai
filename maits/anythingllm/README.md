# MAIT:AnythingLLM

| Field | Value |
|-------|-------|
| **ShortCode** | @MAIT:#AnythingLLM |
| **SME** | AnythingLLM — Private AI Chat & Document Processing Platform |
| **Steward** | @SHD 🇵🇰 (Primary), @MOT 🛠️ (Backup) |
| **Status** | 🟡 Prototype |
| **ALLM Thread** | ✅ `76e9b360-5926-4157-a61c-ba9f878b37c0` (INT-P01, created by @GTM) — dev instance ⏳ PENDING |
| **Instance** | INT-P01 (AI.WeOwn.Agency), dev.weown.tools (dev) |

## About

@MAIT:#AnythingLLM is the subject matter expert for the AnythingLLM platform —
the current AI orchestration layer of the WeOwn ecosystem. ALLM provides the
workspace model (CCC, tools, ADMIN, events, P.O.P.), RAG pipeline, LLM/embedder
configuration, user management, and thread-based agent collaboration that powers
the entire FedArch architecture.

This MAIT covers deployment, workspace operations, MCP integration roadmap, and
the eventual migration to WeOwnLLM.

## Current State

- **Version:** v1.14.1 (fork planned by @GTM)
- **Production:** INT-P01 (AI.WeOwn.Agency) — shared instance
- **Dev:** dev.weown.tools — new instance being populated
- **Developer:** @SHD 🇵🇰

## Related Resources

- [AGENTS.md](AGENTS.md) — Agent instructions (override file)
- [SYSTEM_PROMPT.md](SYSTEM_PROMPT.md) — Thread system prompt
- [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) — Architecture, provisioning flow, Infisical security model, backup strategy
- [docs/WORKSPACE_MODEL.md](docs/WORKSPACE_MODEL.md) — The 5-workspace model, assignment rules, user onboarding
- [docs/RAG_PIPELINE.md](docs/RAG_PIPELINE.md) — Ingestion flow, embedding, folder structure, data connectors
- [docs/MCP_ROADMAP.md](docs/MCP_ROADMAP.md) — MCP integration state, targets, and planned capabilities
- [Deployment (Docker)](../../anythingllm-docker/) — Docker Compose infrastructure
- [Deployment (K8s)](../../anythingllm/) — Kubernetes Helm chart infrastructure

## Changelog

| Date | Change | By |
|------|--------|----|
| 2026-06-25 | Created — initial MAIT prototype | @MOT 🛠️ |
| 2026-06-25 | Added `docs/` — DEPLOYMENT, WORKSPACE_MODEL, RAG_PIPELINE, MCP_ROADMAP | @MOT 🛠️ |
# Workspace Model — MAIT:#AnythingLLM

> #WeOwnVer: v0.1.0 · Status: 🟡 Prototype · Scope: reference for RAG ingestion

AnythingLLM organizes its agents and knowledge into **workspaces**. Each workspace
is an independent environment with its own LLM configuration, vector store, and
agent threads.

---

## The 5 WeOwn Workspaces

| Workspace | Emoji | Purpose |
|-----------|-------|---------|
| **CCC** | 🤝 | Production — CCC-ID generation, user identity, agent authorization |
| **tools** | 🧠 | META orchestration + all MAIT threads |
| **ADMIN** | ⚙️ | Administration — system configuration, instance management |
| **events** | 📆 | Event planning and coordination |
| **P.O.P.** | 🌟 | People, Organizations, Places — relationship tracking |

### CCC 🤝

The production workspace. This is where:
- CCC-IDs are minted and tracked
- User identities are managed
- Agent authorization chains are maintained

All agent actions that produce trackable deliverables originate here.

### tools 🧠

The orchestration layer. This workspace hosts:
- **META Agent** — the coordinator that delegates to MAITs
- **MAIT threads** — one per SME domain (Keycloak, AnythingLLM, Paperless, etc.)
- Context volley processing between agents

MAIT threads are **never created in CCC**. They live in `tools` to keep the
production workspace clean and focused on identity/authorization.

### ADMIN ⚙️

System administration workspace:
- Instance configuration management
- User role assignments
- System health monitoring
- Audit log review

### events 📆

Dedicated workspace for event lifecycle management:
- Event planning and scheduling
- Attendee coordination
- Post-event documentation

### P.O.P. 🌟

Knowledge graph for entities:
- **People** — team members, collaborators, stakeholders
- **Organizations** — partner companies, client entities
- **Places** — physical locations, datacenter regions, meetup venues

---

## Workspace Assignment

### User Onboarding Flow (per GUIDE-008)

1. User requests access through the established protocol
2. Admin creates the user account in the ALLM instance
3. User is assigned to appropriate workspace(s):
   - All team members get `tools` 🧠 access
   - Authorized members get `CCC` 🤝 access
   - Role-based access to `ADMIN` ⚙️, `events` 📆, `P.O.P.` 🌟
4. A `USER-IDENTITY` document is uploaded to the workspace RAG
5. Agent thread permissions are configured per workspace assignment

### Key Rules

- **No automatic workspace assignment** — every assignment is explicit
- **Workspace boundaries are enforced** by the ALLM platform
- **MAITs do not cross workspace boundaries** without explicit direction
- **User credentials do not grant cross-workspace access** by default

---

## Relationship to ALLM Instance Architecture

Each AnythingLLM instance can host multiple workspaces. There is no limit imposed
by the platform, but WeOwn conventions recommend no more than 5-7 workspaces per
instance for maintainability. Multiple instances exist (production, dev) and each
has its own workspace set.
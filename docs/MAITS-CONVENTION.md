# MAIT Convention Framework — WeOwn `ai`

> #WeOwnVer: v4.1.3.1-r1 · Status: 🔄 LIVING · Scope: MAIT prototyping in this repo
>
> Source of truth for how we build, name, structure, and migrate MAITs before the
> `s004_fedarch` repo and AnythingLLM workspace come fully online.
>
> **This document is a bridge.** It translates the PRJ-469 AGENTS.md adoption
> framework into an actionable convention for this repo. When `s004_fedarch/_MAITS_/`
> exists, the MAIT content here moves there with minimal friction.

---

## Table of Contents

1. [Purpose & Authority](#purpose--authority)
2. [What a MAIT Is](#what-a-mait-is)
3. [Design Decisions (Settled)](#design-decisions-settled)
4. [Directory Layout](#directory-layout)
5. [The Template](#the-template)
6. [Override Pattern — Nested AGENTS.md](#override-pattern--nested-agentsmd)
7. [Lifecycle States](#lifecycle-states)
8. [MAIT vs PRJ — The Distinction](#mait-vs-prj--the-distinction)
9. [Security Rules (Public Repo)](#security-rules-public-repo)
10. [Branch & Commit Convention](#branch--commit-convention)
11. [Migration Path to s004_fedarch](#migration-path-to-s004_fedarch)
12. [ALLM Bridge Notes](#allm-bridge-notes)
13. [References](#references)
14. [Version History](#version-history)

---

## 1. Purpose & Authority

### 1.1 Why This Document Exists

The WeOwn ecosystem is adopting `AGENTS.md` as the standard repo-level agent
instruction file (PRJ-469). MAITs (Model-dev / Agent / Instruction / Thread) are
the SME-specific knowledge domains that agents and humans collaborate on. This
document defines **how** we prototype MAITs in `weown/WeOwnNetwork/ai/` before:

- The `s004_fedarch` governance repo exists (PRJ-406, pending)
- The AnythingLLM `workspace:tools` threads are created (ALLM v1.14.1, pending fork)
- The PRJ-469 r3 document lands (being regenerated as of W26 D4)

It is a **living document** — updated as @GTM's architecture solidifies.

### 1.2 Authority Chain

| Layer | Document | Authority |
|-------|----------|-----------|
| Ecosystem | SharedKernel v3.2.2.1 (CCCbotNet/fedarch) | 🔒 LOCKED |
| Governance | BEST-PRACTICES, PROTOCOLS, CCC | 🔒 LOCKED |
| Project | PRJ-469-PROPOSED (AGENTS.md Adoption) | 🟡 PROPOSED |
| **This repo** | **AGENTS.md** at root of `WeOwnNetwork/ai` | ✅ ACTIVE |
| **This doc** | **MAITS-CONVENTION.md** | 🔄 **LIVING** |

This document defers to root `AGENTS.md` on all secrets-hygiene and branch-naming
rules. It DEFINES the MAIT-specific conventions that nested `AGENTS.md` files
implement.

---

## 2. What a MAIT Is

### 2.1 Definition (per SharedKernel D-031)

> **D-031 | MAIT** — Training/Development (human-to-agent, SME-specific).
> A MAIT is a thread in the `workspace:tools` 🧠 workspace of an AnythingLLM
> instance, dedicated to a specific Subject Matter Expert domain.

**Key implication: MAITs are human-to-agent threads.** The primary actor is the
**Steward** (a human), not another agent. Agents may consult a MAIT's documentation
or reference its system prompt, but the thread itself is driven by human training
and development. This distinguishes MAITs from META threads (which are
agent-to-agent production orchestrators).

### 2.2 META vs MAIT — Canonical Distinction

Per SharedKernel v3.2.2.1 (🔒 LOCKED):

| Aspect | META | MAIT |
|--------|------|------|
| **Agent** | #MetaAgent (Calhoun 🎖️) | SME-specific |
| **Actor** | User Agents (AI:@<CCC>) | **Human (Steward)** |
| **Protocol** | #ContextVolley / MCP | #ContextVolley |
| **Purpose** | Production orchestration | **Training/development** |
| **ShortCode** | @META:#MetaAgent | @MAIT:#<SME> |
| **Authority** | Governance + orchestration | READ-ONLY to #MetaAgent (R-200) |
| **Instance** | INT-M01 (META.ccc.bot) | INT-P01 (AI.WeOwn.Agency) or per-org |

### 2.3 Core Attributes

| Attribute | Definition | Example |
|-----------|------------|---------|
| **SME** | Subject Matter Expert domain | Keycloak, AnythingLLM, Paperless-ngx |
| **ShortCode** | Unique identifier in `@MAIT:#<SME>` format | `@MAIT:#Keycloak` |
| **Steward** | Responsible human for the MAIT | `@MOT 🛠️` |
| **Thread UUID** | ALLM thread identifier (placeholder until prototype → active) | `⏳ PENDING` |
| **Instance** | Which ALLM instance hosts the thread | INT-P01 (AI.WeOwn.Agency) |
| **Tool Agent** | Service account username in `t-<TOOL>_tool` format (R-198) | `t-keycloak_tool` |

### 2.4 MAIT Is Both Documentation AND Agent (per @GTM)

From the W26 D4 ad-hoc conversation (GTM_2026-W26_4469):

> *"Is a MAIT an agent or a place for an agent to go learn? It's both. The goal
> around MAITs is to create the documentation, to curate the documentation... The
> MAIT will evolve to a multi-agent orchestration."*

**Layered interpretation:**

| Layer | Now (Prototype) | Later (ALLM Thread) |
|-------|-----------------|---------------------|
| Documentation | `AGENTS.md` + `SYSTEM_PROMPT.md` + `docs/` | Uploaded to RAG |
| Agent | Not yet active | Thread with system prompt + RAG context |
| Orchestration | Conceptual only | Multi-agent coordination around the SME |

---

## 3. Design Decisions (Settled)

These decisions come from the #MetaCouncil VSA on PRJ-469 r2, accepted by @GTM 🎯.

| # | Decision | Source | Implication for MAITs |
|:-:|----------|--------|-----------------------|
| **1** | **Nested = OVERRIDE (nearest wins)** | MetaCouncil consensus, GTM approved | Each `maits/<sme>/AGENTS.md` is **self-contained**. Does NOT merge with root. |
| **2** | **NO symlinks between MAITs and GUIDE-015** | Surge ⚡, DeepPro 🌊, MiMo 🧪, Calhoun 🎖️ | Use markdown links. Symlinks break cross-platform compat. |
| **3** | **Root AGENTS.md ≤ 150–200 lines** | ETH Zurich study + Factory AI guidance | Root stays lean. MAIT complexity lives in nested files. |
| **4** | **Human-curated only (no LLM-generated)** | ETH Zurich study (+4% human, -2% LLM) | Every MAIT AGENTS.md is hand-crafted, never auto-generated. |
| **5** | **Three-layer model** | PRJ-469 §7 | AGENTS.md → GUIDE-015 → PROMPT-*.md. MAITs live at the AGENTS.md layer. |

---

## 4. Directory Layout

### 4.1 MAITs Root

```
weown/WeOwnNetwork/ai/
├── AGENTS.md                        ← Root (repo-level, public-repo-safe)
├── .rules                           ← Zed rules (points to AGENTS.md)
├── CLAUDE.md · GEMINI.md            ← Tool pointer stubs
├── docs/
│   └── MAITS-CONVENTION.md          ← THIS DOCUMENT
├── maits/                           ← ALL MAIT prototypes
│   ├── TEMPLATE.md                  ← Template for creating new MAITs
│   ├── keycloak/                    ← MAIT:#Keycloak
│   │   ├── AGENTS.md                ← Override — self-contained rules
│   │   ├── README.md                ← Human-friendly identity
│   │   └── SYSTEM_PROMPT.md         ← Ready-to-convert system prompt
│   ├── anythingllm/                 ← MAIT:#AnythingLLM
│   │   ├── AGENTS.md
│   │   ├── README.md
│   │   └── SYSTEM_PROMPT.md
│   ├── paperless/                   ← MAIT:#Paperless
│   │   ├── AGENTS.md
│   │   ├── README.md
│   │   └── SYSTEM_PROMPT.md
│   └── ...                          ← More as needed
│
├── (existing infrastructure dirs)
│   ├── anythingllm/                 ← Deployment code (NOT the MAIT)
│   ├── keycloak-docker/             ← Deployment code (NOT the MAIT)
│   └── ...
```

### 4.2 What Goes Where

| Path | Content | Example |
|------|---------|---------|
| `maits/<sme>/AGENTS.md` | Override — rules for interacting with this MAIT | `@MAIT:#Keycloak` identity, allowed actions, NEVER-do |
| `maits/<sme>/README.md` | Human-friendly: SME, Steward, ShortCode, Status, PRJs | Visible on GitHub, no agent-specific instructions |
| `maits/<sme>/SYSTEM_PROMPT.md` | The exact text that becomes the ALLM thread's system prompt | Ready to copy-paste when thread is created |
| `maits/<sme>/docs/` | Reference material (future RAG content) | Research notes, architecture diagrams, guides |

---

## 5. The Template

Every MAIT starts from `maits/TEMPLATE.md`. Here is the template definition:

### 5.1 `maits/<sme>/AGENTS.md`

```markdown
# AGENTS.md — MAIT:<SME-NAME>

> #WeOwnVer: v4.1.3.1 · Status: 🟡 Prototype · Scope: this directory only
>
> Per PRJ-469 §9 (nearest wins / override): this file OVERRIDES root AGENTS.md
> for operations within this MAIT directory. All root-level rules (secrets,
> branching, R-011) still apply unless explicitly overridden below.

## Identity

| Field | Value |
|-------|-------|
| **ShortCode** | `@MAIT:#<SME>` |
| **SME** | <Full SME Name> |
| **Steward** | @<CALLSIGN> |
| **Status** | 🟡 Prototype |
| **Related PRJs** | PRJ-<NNN> |
| **Thread UUID** | ⏳ PENDING (created when ALLM thread is spun up) |
| **Instance** | INT-P01 (AI.WeOwn.Agency) |

## Capabilities

@MAIT:#<SME> can help with:

1. **<Capability 1>** — <What it can do, in concrete action terms>
2. **<Capability 2>** — <What it can do>
3. **<Capability 3>** — <What it can do>
4. **<Capability 4>** — <What it can do>

Each capability links to the relevant `docs/` reference material for deeper context.

## Domain

<2-3 sentence description of what this MAIT is the subject matter expert on.
What questions does it answer? What problems does it solve?>

## Related Infrastructure

| Asset | Path/URL |
|-------|----------|
| Deployment | `<relative-path>` in this repo |
| Runbook | `<relative-path>/OPERATIONS.md` |
| Config | `<relative-path>/` |

## Protocols

- **Communication:** #ContextVolley (per SharedKernel D-032)
- **SYNC:META:** MAIT:SYNC:META (READ-ONLY to #MetaAgent, per R-200)
- **Steward Changes:** #ContextVolley to @MOT 🛠️

## NEVER Do

<MAIT-specific constraints — what this MAIT must never be asked to do>

## System Prompt (for ALLM thread)

This MAIT's system prompt, when the ALLM thread is created, should be:

```markdown
<Exact system prompt text>
```
```

### 5.2 `maits/<sme>/README.md`

```markdown
# MAIT:<SME-NAME>

| Field | Value |
|-------|-------|
| **ShortCode** | @MAIT:#<SME> |
| **Steward** | @<CALLSIGN> |
| **Status** | 🟡 Prototype |
| **AllM Thread** | ⏳ PENDING |
| **Instance** | INT-P01 |

<SME description, 1-2 paragraphs, human-readable>

## Related Resources

- [AGENTS.md](AGENTS.md) — Agent instructions (override file)
- [SYSTEM_PROMPT.md](SYSTEM_PROMPT.md) — Thread system prompt
- [Deployment](../<relative-path>/) — Infrastructure code

## Changelog

| Date | Change | By |
|------|--------|----|
| <date> | Created | @MOT |
```

### 5.3 `maits/<sme>/SYSTEM_PROMPT.md`

```markdown
# System Prompt — MAIT:#<SME>

## Identity

You are @MAIT:#<SME>, the subject matter expert for <SME> within the WeOwn
ecosystem. You operate in the `workspace:tools` 🧠 thread of INT-P01.

## Mission

<2-3 sentences about the MAIT's purpose>

## Capabilities

@MAIT:#<SME> can help you with:

1. **<Capability 1>** — <Action it can take>
2. **<Capability 2>** — <Action it can take>
3. **<Capability 3>** — <Action it can take>
4. **<Capability 4>** — <Action it can take>

## Knowledge

<Key facts the system prompt must embed — the non-inferable knowledge that
an agent wouldn't know from reading the code>

## Boundaries

<What this MAIT will NOT do — hard constraints>

## Communication

- Respond in #ContextVolley format when communicating with other agents
- Use @MAIT:#<SME> as your identifier
- Escalate to Steward (@<CALLSIGN>) for decisions outside your authority
```

---

## 6. Override Pattern — Nested AGENTS.md

### 6.1 How It Works

Per PRJ-469 §9 (OpenAI Codex standard, nearest wins):

| Rule | Behavior | Why |
|------|----------|-----|
| **Nearest wins** | The most deeply nested `AGENTS.md` takes precedence | Tools auto-detect and load the closest file |
| **Root is fallback** | If no nested `AGENTS.md` exists, root applies | MAITs without a file inherit repo rules |
| **No merging** | Nested does NOT merge with parent — it overrides | Tool behavior is deterministic (override, not supplement) |
| **Self-contained** | Each nested `AGENTS.md` must include everything the agent needs | Agents don't "merge" root + nested — they load the closest one |

### 6.2 What Each MAIT AGENTS.md Must Include

To be self-contained, each `maits/<sme>/AGENTS.md` must:

1. ✅ Declare its override relationship to root ("Per PRJ-469 §9...")
2. ✅ Re-state the root rules that remain in effect (secrets, branching, R-011)
3. ✅ Define MAIT-specific rules
4. ✅ Include the system prompt for the future ALLM thread
5. ✅ List NEVER Do items
6. ✅ Define protocols (#ContextVolley, MAIT:SYNC:META)

---

## 7. Lifecycle States

Every MAIT has a lifecycle state tracked in its `README.md` and `AGENTS.md`.

| State | Icon | Meaning | When It Applies |
|-------|:----:|---------|-----------------|
| **Proposed** | ⬜ | Idea stage, not yet built | Before any files exist |
| **Prototype** | 🟡 | Files exist, content being iterated | Current state of all MAITs in this repo |
| **Active** | ✅ | MAIT thread exists in ALLM, system prompt deployed | After ALLM thread creation |
| **Locked** | 🔒 | Stable, changes require Steward approval | After @GTM R-011 for the MAIT |
| **Deprecated** | ❌ | Superseded, not maintained | When replaced by a newer MAIT or SME changes |

### Lifecycle Progression

```text
⬜ Proposed → 🟡 Prototype → ✅ Active → 🔒 Locked
                                    ↓
                                 ❌ Deprecated
```

### Transition Rules

| Transition | Requirement | Approver |
|------------|-------------|----------|
| Proposed → Prototype | AGENTS.md + README exist | @MOT 🛠️ |
| Prototype → Active | ALLM thread created, system prompt deployed, Tool Agent user created per R-198 | Steward |
| Active → Locked | R-011 approval | @GTM 🎯 |
| Active → Deprecated | Replacement MAIT exists or SME retired | @GTM 🎯 |

### Tool Agent Setup Workflow (per BP-026)

When a MAIT transitions from Prototype → Active:

1. **Create Tool Agent user** in `t-<TOOL>_tool` format (R-198) — MUST be done BEFORE thread creation (L-058)
2. **Assign** to `workspace:tools` 🧠
3. **Create MAIT thread** with system prompt from `SYSTEM_PROMPT.md`
4. **Upload RAG docs** from `docs/` — embed in the thread's workspace
5. **Configure** per instance standards
6. **Verify** — thread responds correctly, RAG is searchable

### Existing Production Threads

Some MAITs already have active threads on INT-P01 (AI.WeOwn.Agency), registered
in the **SharedKernel v3.2.2.1 Thread Registry** (canonical source):

| Thread | Steward | Status |
|--------|---------|--------|
| MAIT_AnythingLLM.com | @GTM | ✅ ACTIVE |
| MAIT_Deepnote.com | @GTM | ✅ ACTIVE |
| MAIT_Pinata.cloud | @GTM | ✅ ACTIVE |
| MAIT_Restream.io | @LFG (Primary), @GTM (Backup) | ⬜ PENDING |

For the full canonical registry (UUIDs, Thread URLs), see the SharedKernel at
`CCCbotNet/fedarch/_SYS_/SharedKernel.md`.

---

## 8. MAIT vs PRJ — The Distinction

A MAIT and a PRJ are different artifacts that complement each other. The distinction
matters for understanding what belongs where.

| Aspect | PRJ (Project) | MAIT (Thread) |
|--------|---------------|---------------|
| **D-0xx Definition** | D-020 (User Agent) / D-021 (Tool Agent) — a discrete initiative | D-031 — Training/Development, SME-specific |
| **Purpose** | Deliver a specific outcome (deploy, build, migrate) | Curate knowledge about an SME domain |
| **Duration** | Finite — has phases, then closes | Continuous — as long as the SME exists |
| **Home** | `_PROJECTS_/` in fedarch repo | `workspace:tools` thread in ALLM |
| **Lifecycle** | IDEA → RESEARCH → DRAFT → VSA → R-011 → GH PUSH → ACTIVE → CLOSED | PROPOSED → PROTOTYPE → ACTIVE → LOCKED / DEPRECATED |
| **Document** | `_PROJECTS_/PRJ-NNN.md` (proposal with attestation) | `maits/<sme>/AGENTS.md` (self-contained override) |

### Relationship Examples

| SME | Related PRJ | MAIT Purpose |
|-----|-------------|--------------|
| Keycloak | PRJ-469 (AGENTS.md adoption), R-011 (ACL) | SSO domain knowledge, operations runbook |
| Paperless-ngx | PRJ-013 (deployment), PRJ-469 | Document management SME, ALLM data connector |
| AnythingLLM | PRJ-469, deployment PRs | The platform MAITs run on |

**Rule of thumb:** If it has a finish line, it's a PRJ. If it's ongoing domain
knowledge, it's a MAIT.

---

## 9. Security Rules (Public Repo)

**THIS REPO IS PUBLIC.** All MAIT content in `maits/` must follow the same
secrets hygiene as the rest of the repo (per root `AGENTS.md`).

### 9.1 Never Commit in MAIT Files

- Real IPs, hostnames, or domain names (use `203.0.113.x` RFC 5737, `example.com` RFC 2606)
- Cluster names, node-pool names, kubeconfig contexts
- API keys, tokens, passwords, credentials
- DO Spaces bucket names, PV IDs, internal DNS
- PII of any kind
- ALLM thread URLs with real instance domains (use placeholder: `https://<instance>/workspace/tools/t/<uuid>`)

### 9.2 MAIT-Specific Security Rules

| Rule | Reason |
|------|--------|
| `SYSTEM_PROMPT.md` contains NO secrets | System prompts are visible to anyone with thread access |
| `AGENTS.md` describes protocols, not credentials | Agents load this file — secrets in context are exfiltratable |
| Thread UUIDs are placeholders until ALLM is ready | Real UUIDs + instance URLs = attack surface |
| RAG content descriptions are generic | Don't describe sensitive document contents in a public repo |

---

## 10. Branch & Commit Convention

Per root `AGENTS.md` (CI-enforced):

```regex
^(feature|fix|docs|hotfix)/[a-z0-9]{2,}-[a-z0-9]{3,}(-[a-z0-9]+)*$
```

| Use | Convention | Example |
|-----|------------|---------|
| **New MAIT prototype** | `feature/mot-<sme>-mait` | `feature/mot-keycloak-mait` |
| **Update to convention** | `docs/mot-maits-update` | `docs/mot-maits-update` |
| **Fix in MAIT content** | `fix/mot-<sme>-mait-desc` | `fix/mot-keycloak-mait-desc` |

**Commit message format:**

```
type(maits): <sme> — <description>

#WeOwnVer: v4.1.3.1
```

**Examples:**

```
feat(maits): keycloak — initial MAIT prototype with AGENTS.md + system prompt

docs(maits): convention — update migration path after @GTM PRJ-469 r3

fix(maits): anythingllm — correct Steward assignment
```

---

## 11. Migration Path to s004_fedarch

When `s004_fedarch` repository is created (PRJ-406) and MAITs get their
canonical home in `_MAITS_/`, the migration is:

### Step 1: Move Content

```bash
# From WeOwnNetwork/ai
git mv maits/ /path/to/s004_fedarch/_MAITS_/
```

### Step 2: Create Backward Symlink

```bash
# In WeOwnNetwork/ai
ln -s /path/to/s004_fedarch/_MAITS_ maits
```

### Step 3: Update References

- Root `AGENTS.md` in `s004_fedarch` links to `_MAITS_/`
- Each MAIT's `AGENTS.md` updates its `Related Infrastructure` paths if they change
- `docs/MAITS-CONVENTION.md` is archived in `s004_fedarch/_GUIDES_/` or _SYS_/

### Why This Works

| Reason | Detail |
|--------|--------|
| **Content is format-agnostic** | Markdown files move trivially |
| **Override pattern is identical** | Nested AGENTS.md with nearest wins is the same in both repos |
| **Symlinks preserve history** | Old repo still resolves, new repo is canonical |
| **No ALLM dependency** | Content moves independently of thread creation |

---

## 12. ALLM Bridge Notes

### 12.1 Landscape

| Component | INT-P01 (Prod) | Dev (dev.weown.tools) |
|-----------|----------------|----------------------|
| ALLM version | v1.14.1 | Being set up by @SHD 🇵🇰 |
| `workspace:tools` threads | ✅ Multiple active MAITs exist | ⏳ Not yet created |
| MCP schemas for MAITs | ⏳ Check SharedKernel Thread Registry | ❌ Future |

**Key fact:** MAITs for **AnythingLLM**, **Deepnote.com**, and **Pinata.cloud**
already have active threads on INT-P01 with real UUIDs, registered in the
canonical SharedKernel v3.2.2.1. These were created by @GTM directly.
Our prototypes in `maits/` are iterating toward those production threads.

### 12.2 What We're Bridging

From the W26 D4 transcript — @GTM:

> *"The big misunderstanding was this idea that everything needs to be done
> through AnythingLLM — that's not accurate at all. We need to use that for
> CCC-ID until we get OpenClaw."*

And from Peter (@MOT):

> *"I'm on Zed because I still can't work with AnythingLLM yet. The three of us
> [MOT, GTM, CTO] demonstrated this yesterday — synchronous on three different
> systems. That's system agnostic."*

**Key insight:** The MAIT content we build now is system-agnostic. It works in
Zed, in GitHub, in ANY tool that reads `AGENTS.md`. When ALLM is ready, the
content is simply uploaded to RAG and referenced in the thread system prompt.

### 12.3 When ALLM Threads Are Created

For each MAIT, the transition to an ALLM thread requires:

| Artifact | Source | Action |
|----------|--------|--------|
| System prompt | `maits/<sme>/SYSTEM_PROMPT.md` | Copy into thread configuration |
| Tool Agent user | Created per R-198 (`t-<TOOL>_tool`) | MUST precede thread creation (L-058) |
| RAG content | `maits/<sme>/docs/` content | Upload to workspace and embed |
| Thread UUID | Generated by ALLM | Insert placeholder in `AGENTS.md` and `README.md` |
| Steward assignment | From `README.md` | Confirm with the human |
| MCP tool config | Future | Configure per MAIT needs |

---

## 13. References

### 13.1 Ecosystem Documents

| Document | Version | Location |
|----------|---------|----------|
| SharedKernel | v3.2.2.1 | `CCCbotNet/fedarch/_SYS_/SharedKernel.md` |
| BEST-PRACTICES | v3.1.3.1 | `CCCbotNet/fedarch/_SYS_/BEST-PRACTICES.md` |
| CCC | v3.1.3.1 | `CCCbotNet/fedarch/_SYS_/CCC.md` |
| PROTOCOLS | v3.1.3.1 | `CCCbotNet/fedarch/_SYS_/PROTOCOLS.md` |

### 13.2 Project Documents

| Document | Version | Status | CCC-ID |
|----------|---------|--------|--------|
| PRJ-469-PROPOSED (AGENTS.md Adoption) | v4.1.3.1-r2 | 🟡 PROPOSED | GTM_2026-W26_2081 |
| PRJ-406 (Git Architecture) | — | 🟡 DRAFT | GTM_2026-W26_2056 |

### 13.3 Source Transcripts

| Source | File (local) |
|--------|--------------|
| @GTM + @MOT ad-hoc (W26 D4) | `scratch/@gtm-chat-w26-4001.vtt` |
| All-Morning Daily Sync (W26 D4) | `scratch/@all-morn-meeting.vtt` |

---

## 14. Version History

| Version | Date | Change | Author |
|---------|------|--------|--------|
| v4.1.3.1-r1 | 2026-06-25 | Initial — MAIT Convention Framework based on PRJ-469 r2 + MetaCouncil VSA + W26 D4 transcripts | AI:@MOT 🛠️ |
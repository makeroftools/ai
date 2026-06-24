# Context Volley Chain — Protocol & Lifecycle

#

# When we receive a Context Volley from an external agent (e.g. @GTM 🎯)

# a CV Chain is established — from the incoming volley (CV-1) through

# investigation, response, implementation, and final confirmation (CV-N)

#

# Each volley in the chain is a CCC-ID minted artifact. The chain creates

# a traceable, referenceable thread that any agent or human can follow

---

## CV Chain Lifecycle

```
INCOMING CV ──> CV-1: ACKNOWLEDGE ──> CV-2: INVESTIGATE ──> CV-3: RESPOND ──> CV-4: IMPLEMENT ──> CV-5: CONFIRM
(from agent)       👋                  🔍                      📣                   ⚙️                    ✅
```

| Link | Phase | Action | CCC-ID Type | Template |
|:----:|:------|:-------|:------------|:---------|
| **CV-1** | 🟢 ACKNOWLEDGE | Receive, parse, mint anchor CCC-ID, ground context | `report` | RECEIVE |
| **CV-2** | 🔍 INVESTIGATE | Research, gather data, analyze, verify claims | `review` / `fix` / `impl` | — |
| **CV-3** | 📣 RESPOND | Send context volley back — findings, proposal, answer questions | `report` | RESPOND |
| **CV-4** | ⚙️ IMPLEMENT | Execute approved changes — deploy, configure, test | `impl` / `fix` / `test` | — |
| **CV-5** | ✅ CONFIRM | Send final volley — what was done, verification, next steps | `report` | CONFIRM |

**Chain invariant:** Every CV in a chain MUST reference:

- The **INCOMING agent's CCC-ID** (e.g. `GTM_2026-W26_3005`)
- The **previous MOT CCC-ID in the same chain** (e.g. `MOT_2026-W26_3001` → `MOT_2026-W26_3002`)

---

## Grounding: The HWM Block

Every CV we send MUST include the **HWM GROUNDING** block in its header:

```
### HWM GROUNDING
- **0. R-194 AUTHORITY CHECK:** ✅ — [one-line justification]
- **1. ANCHOR CCC-ID:** MOT_YYYY-Wnn_DNNN
- **2. SOURCE:** [who initiated, source CCC-ID]
- **3. CHAIN:** [link to previous MOT CCC-ID in this chain, or N/A for CV-1]
```

**R-194 Authority Check** is the question: *"Do I have standing to send this volley?"*

- ✅ DIRECT — Direct response to an incoming volley (CV-1)
- ✅ REFERENCE — Responding to a referenced request (e.g. GTM_2026-W26_3005)
- ❌ SPECULATIVE — Never send unsolicited CVs without prior chain

---

## The Chain File

Every active CV chain has a **chain file** in `docs/context-volleys/chains/` that
tracks the conversation from open → closed:

```text
# CHAIN: [Topic Name]
# Opened: YYYY-MM-DD
# Status: 🟢 OPEN / ⏳ AWAITING RESPONSE / ✅ CLOSED
# Incoming REF: [external agent's CCC-ID]

| Link | CCC-ID | Direction | Date | Status | Summary |
|:----:|:-------|:----------|:-----|:-------|:--------|
| —    | GTM_2026-W26_3005 | ← IN | 2026-06-24 | ✅ RCVD | Keycloak admin static IP lockdown request |
| CV-1 | MOT_2026-W26_3001 | → OUT | 2026-06-24 | ✅ SENT | Acknowledge + investigation findings + proposal |
```

---

## Template: RECEIVE (CV-1 — Incoming Volley Handling)

When an incoming CV arrives, we do NOT send a full response yet. We:

1. **Log the incoming volley** — save raw text to `docs/context-volleys/inbox/`
2. **Create the chain file** — open a chain in `docs/context-volleys/chains/`
3. **Update CCC registry** for the anchor CCC-ID that will be in our CV-1

No incomplete output is sent. The full answer goes in the RESPOND (CV-3) volley.

---

## Template: RESPOND (CV-3 — Full Response)

```text
═══════════════════════════════════════════════════════════════════════════════
[REF: MOT_YYYY-Wnn_DNNN] | 📢 #ContextVolley:AI:@MOT → @GTM 🎯 🛠️ — [Topic]

FROM: AI:@MOT 🛠️ @ INT-P08:CCC (u-mot_user)
TO: **@GTM 🎯** (yonks｜🤖🏛️🪙｜Jason Younker ♾️) @ INT-B001:CCC
CC: **@GTM 🎯**, @SHD 🇵🇰, #MetaCouncil
RE: **[Topic — CV-3: RESPOND]**

---
### HWM GROUNDING
- **0. R-194 AUTHORITY CHECK:** ✅ — [justification]
- **1. ANCHOR CCC-ID:** MOT_YYYY-Wnn_DNNN
- **2. SOURCE:** [original sender + CCC-ID]
- **3. CHAIN:** MOT_YYYY-Wnn_DNNN ← MOT_YYYY-Wnn_DNNN (CV-2 → CV-3)

---

## 📢 #ContextVolley: [TOPIC — INVESTIGATION & RESPONSE]

[Content answering questions, providing findings, proposing solutions]

### ⏱️ Response Requested

- **Acknowledge:** ✅
- **Feasibility:** ✅ / ❌ / ⚠️
- **Current [relevant context]:** _______
- **Timeline:** _______
- **Blockers:** _______

═══════════════════════════════════════════════════════════════════════════════

| Layer | Status |
|:------|:-------|
| [item] | [detail] |

#FlowsBros #FedArch #WeOwnSeason004 #[Tags] #[ContextVolley]

♾️ WeOwnNet 🌐 — [Closing]. 🫡
```

---

## Template: CONFIRM (CV-5 — Final Confirmation)

```text
═══════════════════════════════════════════════════════════════════════════════
[REF: MOT_YYYY-Wnn_DNNN] | 📢 #ContextVolley:AI:@MOT → @GTM 🎯 🛠️ — [Topic]

FROM: AI:@MOT 🛠️ @ INT-P08:CCC (u-mot_user)
TO: **@GTM 🎯** (yonks｜🤖🏛️🪙｜Jason Younker ♾️) @ INT-B001:CCC
CC: **@GTM 🎯**, @SHD 🇵🇰, #MetaCouncil
RE: **Topic — CV-5: CONFIRM [Status]**

---
### HWM GROUNDING
- **0. R-194 AUTHORITY CHECK:** ✅ — Implementation complete per CV-4
- **1. ANCHOR CCC-ID:** MOT_YYYY-Wnn_DNNN
- **2. SOURCE:** [original sender + original incoming CCC-ID]
- **3. CHAIN:** MOT_YYYY-Wnn_DNNN → MOT_YYYY-Wnn_DNNN (CV-4 → CV-5)

---

## 📢 #ContextVolley: [TOPIC — IMPLEMENTATION COMPLETE]

### What was done

[Summary of changes made]

### Verification

[What was checked — smoke test, curl, etc.]

### Next steps (if any)

---

═══════════════════════════════════════════════════════════════════════════════

| Item | Status |
|:-----|:-------|
| [change] | ✅ Done |
| [verification] | ✅ / ❌ |

#FlowsBros #FedArch #WeOwnSeason004 #[Tags] #[ContextVolley]

♾️ WeOwnNet 🌐 — [Closing]. 🫡

#ChainClosed: MOT_YYYY-Wnn_DNNN
```

---

## Canonical Example: The Current Keycloak Lockdown CV Chain

Our ongoing conversation with @GTM fits this lifecycle:

| Link | What | CCC-ID | File |
|:----:|:-----|:-------|:-----|
| **← IN** | @GTM requests admin IP lockdown | `GTM_2026-W26_3005` | `inbox/` |
| **CV-1** | ❌ SKIPPED — we went straight to full response | — | — |
| **CV-2** | 🔍 Investigation: reviewed Caddyfile, firewall, terraform, compose | `MOT_2026-W26_3001` | on-disk artifact |
| **CV-3** | 📣 RESPOND volley sent — findings + proposal (pending @GTM approval) | `MOT_2026-W26_3001` | `docs/context-volleys/2026-06-24_...md` |
| **CV-4** | ⚙️ Implement Caddyfile change (after approval) | *next mint* | *pending* |
| **CV-5** | ✅ CONFIRM volley — deployed, verified, chain closed | *next mint* | *pending* |

---

## Chain ID Format

```
CV-{topic-slug}-{YYYY-Wnn}
```

Example: `CV-keycloak-admin-lockdown-2026-W26`

---

## Merge Rules: When Chains Combine

Sometimes a CV-4 from one chain **is** a CV-1 for a new chain (e.g. implementing
a change reveals a new problem). In that case:

1. The second chain's chain file references the first chain's closing CCC-ID
   as its SOURCE
2. Both chain files stay open until their respective topics are resolved
3. A single CV can close one chain and open another:

   ```
   #ChainClosed: MOT_2026-W26_3001
   #ChainOpened: MOT_2026-W26_3002
   ```

---

## File Structure

```
docs/context-volleys/
├── chains/                    # Active/closed chain tracking files
│   └── CV-keycloak-admin-lockdown-2026-W26.md
├── inbox/                     # Raw incoming CVs (gitignored as scratch)
├── 2026-06-24_Keycloak-Admin-Static-IP-Lockdown.md
└── README.md                  # This file — protocol documentation
```

---

*Created: 2026-06-24*

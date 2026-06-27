# Intelligence: MAIT-internal _PROMPTS_ Repository Structure

> Date: 2026-06-26 (W26 D5)
> Source: Cloned WeOwnAgents/MAIT-internal — @GTM repository
> Status: ✅ ACCESS CONFIRMED (cloned locally)
> Tags: `#MAIT` `#Internal` `#PromptTemplate` `#GoldStandard` `#OpenTofu`

---

## Repository: MAIT-internal

**URL:** https://github.com/WeOwnAgents/MAIT-internal
**Visibility:** INTERNAL (private, internal org)
**Cloned to:** `weown/WeOwnAgents/MAIT-internal/`
**Content:** `_PROMPTS_/` folder + `README.md`

```
MAIT-internal/
├── README.md                    ← "MAIT (visibility = INTERNAL)"
└── _PROMPTS_/
    └── PROMPT-INT-P08-MAIT-OPENTOFU.md   ← First MAIT workspace prompt (433 lines)
```

---

## PROMPT-INT-P08-MAIT-OPENTOFU.md — Key Details

| Field | Value |
|-------|-------|
| **Version** | v4.1.3.1-r2 |
| **Category** | 🛤️ MAIT WORKSPACE PROMPT |
| **Status** | 🟢 LIVE — OpenTofu MAIT Agent on INT-P08 |
| **Author** | AI:@GTM 🎯 @ INT-B001:CCC (GTM_2026-W26_4014) |
| **Model** | DeepSeek V4 Flash (1M context) |
| **Workspace** | dev.weown.tools/workspace/mait-opentofu |
| **Thread** | /t/758ad5ea-da47-4653-ae7c-305f9abb8026 |
| **Instance** | INT-P08 (Dev.WeOwn.Tools) |
| **Stewards** | @CTO 🧱 (Lead), @SHD 🇵🇰 (IaC), @MWK 🕺 (Tech Lead) |
| **R-194** | ❌ REFERENCE ONLY — Cannot generate CCC-IDs |
| **R-011** | ❌ Cannot approve — @CTO or @GTM must approve |

---

## 17-Section #GoldStandard Template

| § | Section | Purpose |
|:-:|---------|---------|
| 1 | #StartWithWhy | Why this MAIT exists |
| 2 | MAIT WORKSPACE IDENTITY | Non-CCC rules, key responsibilities |
| 3 | IDENTITY GATE & USAGE RULES | R-011 approval matrix |
| 4 | #FELG ALIGNMENT | Culture layer |
| 5 | TOOL-FIRST MODE | #DeepResearch Protocol (L-406) |
| 6 | ECOSYSTEM CONTEXT | BP-226 4-layer stack, tiered grounding |
| 7 | MAIT ECOSYSTEM — ALL MAIT ASSETS | Full table (21 total MAITs) |
| 8 | TIMESTAMP & PRIORITY | Temporal awareness |
| 9 | TASK ROADMAP | P0/P1/P2 task list |
| 10 | THREE GREAT INITIATIONS | GUIDE-015 |
| 11 | FOUR RESPONSE THEMES | Response structure |
| 12 | RESPONSE FORMAT & TOOL HYGIENE | Pure markdown, no CCC-ID, RAG protocol |
| 13 | #BadAgent PROTOCOL | L-211 |
| 14 | IMMUTABLE RULES | State is Sacred |
| 15 | PINNED DOCS & REFERENCES | R-204 |
| 16 | MAIT AGENT INITIATION CHECKLIST | 10-item checklist |
| 17 | #GoldStandard MARKER | Template copy instructions + BP-075 footer |

---

## MAIT Ecosystem — Known Assets (§7 registry)

| # | MAIT | Type | Purpose | Lead |
|:-:|:-----|:----:|:--------|:-----|
| 1 | OpenTofu | 🛤️ IaC | IaC + MCP | @CTO 🧱, @SHD 🇵🇰, @MWK 🕺 |
| 2 | Twilio | 📞 Comms | SMS, Voice, WhatsApp | @SHD 🇵🇰, @GTM 🎯 |
| 3 | SigNoz | 📊 Observability | APM monitoring | @CTO 🧱, @SHD 🇵🇰 |
| 4 | DigitalOcean | ☁️ Cloud | Cloud provider | @PLT 🌊 |
| 5 | kagent.dev | 🤖 AI | AI agent dev platform | @PLT 🌊 |
| 6 | KeyCloak | 🔑 Identity | SSO, IAM | **@MOT 🛠️** |
| 7-21 | +15 more | Various | Unlisted in this file | Various |

**21 total MAIT assets** in @GTM's ecosystem. KeyCloak (#6) is our domain.

---

## Key Design Decisions (MAIT Workspace Convention)

| Decision | Rationale |
|:---------|:----------|
| **NO CCC-ID generation** | MAIT agents execute, not govern (R-194) |
| **REFERENCE CCC-IDs only** | Governance flows from CCC agents |
| **Explicit R-011 matrix** | Know WHO approves WHAT before acting |
| **Tool-First Mode** | Real tools, not training data inference |
| **State is Sacred** | Plan → review → apply discipline |

---

## Implications for Our MAIT Work

1. **OpenTofu MAIT is already 🟢 LIVE on INT-P08** — @GTM deployed this before we knew
2. **Our META vs MAIT distinction (§2.2) is validated** — the prompt enforces non-CCC rules
3. **`_PROMPTS_/` is a prompt archive** — confirms content stays in `_MAITS_/` or `maits/`
4. **21 MAIT assets total** — we only have 3 documented. 18 unaccounted for
5. **#GoldStandard template** — should reconcile against our MAITS-CONVENTION.md §5 template
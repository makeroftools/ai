# Intelligence: WeOwnAgents GitHub Organization — Updated State

> Date: 2026-06-26 (W26 D5)
> Source: @GTM 🎯 dev channel messages
> Status: Discovered, not yet actioned

---

## Organization: github.com/WeOwnAgents

Created by @GTM. Two repos discovered:

### Repo 1: `MAIT` (public, MIT License)

- Repo: https://github.com/WeOwnAgents/MAIT
- **Status:** 🟢 Empty repo — exists, no commits
- Previously tracked as "unknown intent" — now confirmed public-facing
- Repo was cloned to workspace at `weown/WeOwnAgents/MAIT`
- @GTM has NOT yet committed anything here

### Repo 2: `MAIT-internal` (INTERNAL ONLY)

- Repo: https://github.com/WeOwnAgents/MAIT-internal
- **Status:** 🟢 ACTIVE — @GTM has committed here
- Contains `_PROMPTS_/` folder structure
- Known file: `_PROMPTS_/PROMPT-INT-P08-MAIT-OPENTOFU.md`
  - URL: https://github.com/WeOwnAgents/MAIT-internal/blob/main/_PROMPTS_/PROMPT-INT-P08-MAIT-OPENTOFU.md
- **NOTE:** This is INTERNAL ONLY — do NOT commit, reference in public docs, or clone without authorization

---

## #GoldStandard #WorkspacePrompt — 5 Agent Types

@GTM identified 5 agent types that a unified workspace prompt must cover:

| # | Agent Type | Description | Status |
|:-:|-----------|-------------|--------|
| 1 | **CCC** | Human contributors | 🟢 Known |
| 2 | **MAIT Agents** | SME-specific MAIT agents | 🟢 Convention exists |
| 3 | **VSA Agents** | VSA ecosystem coordination | 🟡 New — in s004_fedarch design |
| 4 | **Tools Agents** | Tool/skill agents | 🟡 New — being defined |
| 5 | **DRP Agents** | Deep Research Protocol agents | 🟡 New — likely URL/workspace slug |

---

## Implications

- WeOwnAgents intent is NO LONGER unknown — @GTM is actively using MAIT-internal
- The 5-agent typology informs s004_fedarch's folder structure (each → a root-level file)
- MAIT-internal's `_PROMPTS_/` pattern suggests prompt archive, not MAIT content home
- Public MAIT repo remains empty — may be the eventual home for individual MAIT content files
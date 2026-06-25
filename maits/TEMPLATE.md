# MAIT Template

> #WeOwnVer: v4.1.3.1 · Status: 🟡 Prototype · Scope: MAIT definition
>
> Copy this directory to create a new MAIT. Replace `<SME-NAME>` and `<sme>`
> with the actual SME identifier.

---

## Files to Create

```
maits/<sme>/
├── AGENTS.md          ← Self-contained override — MAIT identity, rules, system prompt
├── README.md          ← Human-friendly — SME, Steward, ShortCode, Status
└── SYSTEM_PROMPT.md   ← Ready-to-convert system prompt for the future ALLM thread
```

### Required Fields

| Field | Where | Example |
|-------|-------|---------|
| `ShortCode` | AGENTS.md + README.md | `@MAIT:#Keycloak` |
| `SME` | AGENTS.md + README.md | Keycloak |
| `Steward` | AGENTS.md + README.md | `@MOT 🛠️` |
| `Status` | AGENTS.md + README.md | `🟡 Prototype` |
| `Related PRJs` | AGENTS.md | `PRJ-469` |
| `Deployment path` | AGENTS.md | Relative path to infrastructure dir in this repo |

### Optional Fields

| Field | When Needed | Example |
|-------|-------------|---------|
| `Related PRJs` | When MAIT connects to an existing project | `PRJ-013` for Paperless |
| `docs/` directory | When there's reference material for future RAG | Research notes, guides |

---

## Lifecycle Checklist

| Step | What to Update | Done When |
|------|----------------|-----------|
| ⬜ Proposed | Idea shared with Steward | Before creating files |
| 🟡 Prototype | AGENTS.md + README.md + SYSTEM_PROMPT.md exist and reviewed | Files created, branch pushed |
| ✅ Active | Thread UUID populated | ALLM thread created |
| 🔒 Locked | Status changed, R-011 approved | @GTM approval |

---

## Template Source

See `docs/MAITS-CONVENTION.md` §5 for the full template definitions with all
required sections and formatting.
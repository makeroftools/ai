# Convention-to-GoldStandard Reconciliation — MAIT Template Diff

> Date: 2026-06-26 (W26 D5)
> Author: @MOT 🛠️
> Purpose: Compare MAITS-CONVENTION.md §5 template vs PROMPT-INT-P08-MAIT-OPENTOFU.md (v4.1.3.1-r2)
> Status: ⏳ Pre-CS-406 analysis — no changes, just mapping
> Tags: `#MAIT` `#Convention` `#GoldStandard` `#Template` `#Diff` `#Reconciliation`

---

## Overview

Two templates exist for MAIT content. They serve different contexts but must
reconcile before CS-406 migration:

| Template | File | Context | Sections |
|----------|------|---------|:--------:|
| **Convention** (§5) | `maits/<sme>/AGENTS.md` + `SYSTEM_PROMPT.md` | Git-level MAIT content (public repo) | 3 files, ~6 sections each |
| **GoldStandard** (v4.1.3.1-r2) | `PROMPT-INT-P08-MAIT-OPENTOFU.md` | ALLM workspace prompt (internal) | 17 sections, single file |

---

## Structural Comparison

### Convention §5 Template (Current — 3-file pattern)

| File | Sections | Lines | Context |
|------|----------|:-----:|:--------|
| `AGENTS.md` | Identity, Capabilities, Domain, Related Infrastructure, Protocols, NEVER Do, System Prompt | ~55 | Git-level agent instruction (public) |
| `README.md` | Identity, SME, Steward, Changelog | ~35 | Human-readable intro (public) |
| `SYSTEM_PROMPT.md` | Identity, Mission, Capabilities, Knowledge, Boundaries, Communication | ~40 | ALLM thread system prompt (public) |
| **Total** | **~15 unique sections across 3 files** | **~130** | |

### GoldStandard Template (Single-file prompt in MAIT-internal)

| § | Section | Lines | Context |
|:-:|---------|:-----:|:--------|
| 1 | #StartWithWhy | ~30 | Mission + Three Pillars |
| 2 | MAIT WORKSPACE IDENTITY | ~35 | R-194, Key Responsibilities |
| 3 | IDENTITY GATE & USAGE RULES | ~25 | R-011 approval matrix |
| 4 | #FELG ALIGNMENT | ~15 | Culture layer |
| 5 | TOOL-FIRST MODE | ~15 | #DeepResearch (L-406) |
| 6 | ECOSYSTEM CONTEXT | ~45 | BP-226 4-layer stack, tiered grounding |
| 7 | MAIT ECOSYSTEM — ALL ASSETS | ~15 | Full 21-MAIT registry |
| 8 | TIMESTAMP & PRIORITY | ~7 | Temporal awareness |
| 9 | TASK ROADMAP | ~30 | P0/P1/P2 with dependencies |
| 10 | THREE GREAT INITIATIONS | ~8 | GUIDE-015 (Search Before Declaring, Prove Before Acting) |
| 11 | THE FOUR RESPONSE THEMES | ~10 | Forge/Lab/Keep/Vault |
| 12 | RESPONSE FORMAT & TOOL HYGIENE | ~40 | Pure markdown, no CCC-ID, RAG proxy protocol |
| 13 | #BadAgent PROTOCOL | ~12 | L-211: ACK → LOG → CORRECT → LEARN |
| 14 | IMMUTABLE RULES | ~12 | R-194, R-011, BP-226, L-406, L-097, State |
| 15 | PINNED DOCS & REFERENCES | ~20 | R-204, SharedKernel, references |
| 16 | MAIT AGENT INITIATION CHECKLIST | ~15 | 10-item checklist |
| 17 | #GoldStandard MARKER | ~75 | Template copy instructions, BP-075 footer |
| **Total** | **17** | **~433** | |

---

## Gap Analysis: What Convention is Missing vs GoldStandard

| Gap | GoldStandard § | Convention Has? | Impact |
|:----|:--------------:|:---------------|:-------|
| **#StartWithWhy** | §1 | ❌ No | Missing mission/purpose framing |
| **R-194 (NO CCC-ID)** | §2, §12, §14 | ❌ No | Our MAITs don't enforce non-CCC workspace rules |
| **R-011 approval matrix** | §3 | ❌ No | No "who approves what" in our template |
| **FELG alignment** | §4 | ❌ No | Missing culture layer |
| **Tool-First Mode** | §5 | ❌ No | No L-406 enforcement |
| **Ecosystem context (BP-226)** | §6 | ❌ No | No 4-layer stack or tiered grounding |
| **MAIT registry** | §7 | ❌ No | No cross-MAIT ecosystem awareness |
| **Timestamp/priority** | §8 | ❌ No | No temporal awareness |
| **Task roadmap** | §9 | ❌ No | No P0/P1/P2 planning |
| **Response themes** | §11 | ❌ No | No Forge/Lab/Keep/Vault pattern |
| **Tool hygiene (no XML)** | §12 | ❌ No | No RAG proxy protocol |
| **BadAgent protocol** | §13 | ❌ No | No L-211 incident handling |
| **Immutable rules** | §14 | ❌ No | No consolidated rule set |
| **Initiation checklist** | §16 | ❌ No | No agent startup checklist |
| **BP-075 footer** | §17 | ❌ No | No self-verifying footer |

---

## What GoldStandard is Missing vs Convention

| Feature | Convention § | GoldStandard Has? | Notes |
|:--------|:-----------:|:-----------------:|:------|
| **Public repo hygiene** | §9 | ❌ No | GoldStandard is INTERNAL — doesn't need it |
| **Branch/commit convention** | §10 | ❌ No | Git workflow — irrelevant for ALLM prompt |
| **Migration path** | §11 | ❌ No | Only applies to `weown/WeOwnNetwork/ai/` |
| **ALLM bridge notes** | §12 | ❌ No | Thread creation protocol — covered elsewhere |
| **META vs MAIT distinction** | §2.2 | ❌ No | GoldStandard knows it's a MAIT implicitly |
| **Nested AGENTS.md override** | §6 | ❌ No | Git concept — doesn't apply to single prompt |
| **3-file split (AGENTS.md + README + SYSTEM_PROMPT)** | §5 | ❌ No | GoldStandard is single file — different context |

---

## Key Insight: They Serve Different Layers

```
Git Layer (Public — Convention)                  ALLM Layer (Internal — GoldStandard)
┌──────────────────────────────────┐            ┌──────────────────────────────────┐
│  maits/<sme>/AGENTS.md           │            │  MAIT workspace prompt           │
│  maits/<sme>/README.md           │  ───ingest──▶  (17 sections, 433 lines)       │
│  maits/<sme>/SYSTEM_PROMPT.md    │   ▶ RAG    │                                  │
│  maits/<sme>/docs/*.md           │            │  §1 StartWithWhy                 │
│                                  │            │  §2 Identity + R-194             │
│  Human-readable, Git-versioned,  │            │  §3 R-011 matrix                 │
│  Public-repo-safe                │            │  §4 FELG                         │
└──────────────────────────────────┘            │  §5 Tool-First                   │
                                                │  §6 Ecosystem (BP-226)           │
                                                │  §7 21-MAIT registry             │
                                                │  §8-17: Runtime protocol         │
                                                └──────────────────────────────────┘
```

**The Convention defines the source content.** The GoldStandard is the **runtime system prompt** that agents load. They're not competing — the Convention feeds into the GoldStandard via RAG ingestion.

However, there are structural elements in the GoldStandard that **should influence the Convention** because they represent design decisions about MAIT agents (R-194 enforcement, R-011 matrix, BP-226 ecosystem context, immutable rules).

---

## Recommendation for Migration (when CS-406 drops)

| Priority | Action | Reason |
|:--------:|:-------|:-------|
| 🔴 P0 | **Add R-194 clause** to §5: "MAITs are non-CCC — no CCC-ID generation" | Currently absent from convention. Fundamental governance rule. |
| 🔴 P0 | **Add R-011 approval matrix** to §5: who approves what for each MAIT | Currently absent. Critical for operational safety. |
| 🟠 P1 | **Add BP-226 ecosystem context** to §5: where this MAIT fits in the 4-layer stack | Users need to understand the architecture. |
| 🟠 P1 | **Add immutable rules section** to §5: consolidated rule set per MAIT | Prevents ambiguous agent behavior. |
| 🟡 P2 | **Add initiation checklist** to §5: agent startup sequence | Currently only in GoldStandard — useful in both layers. |
| 🟢 P3 | **Add Forge/Lab/Keep/Vault response themes** | Stylistic — adopt if team wants consistency. |

**Note:** All of these changes should WAIT for CS-406 as @GTM requested. This diff is a preparatory analysis, not an action plan.

---

## One Structural Question for CS-406

```
Convention:     3 files (AGENTS.md + README.md + SYSTEM_PROMPT.md)
                 ↕ Split by audience
GoldStandard:   1 file (single 17-section system prompt)
                 ↕ Unified by workspace
```

When CS-406 defines the migration: will MAIT content in `_MAITS_/` remain as
individual files (Convention pattern) that RAG ingests into a single prompt
(GoldStandard pattern)? Or will `_MAITS_/` adopt the 17-section format directly?

The RAG ≠ Git framework suggests **Convention feeds GoldStandard** — both
formats coexist at different layers. Worth confirming when CS-406 lands.
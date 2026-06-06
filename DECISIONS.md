# Architectural and Process Decisions

This document records significant decisions made during project development to provide context for future work and prevent re-debating the same issues.

---

## AD-001: Tiered Machine Identity Model for Automated Deployment

**Date:** 2026-06-06  
**Status:** Implemented  
**Context:** Need to automate Infisical project creation while maintaining security

**Decision:** Use two-tier MI architecture:

- **Tier 1 (Bootstrap MI):** High privilege, limited scope, stored in operator-tools project
- **Tier 2 (Site MI):** Low privilege, site-scoped, rotated on first boot

**Consequences:**

- ✅ Positive: Automated deployment, strong security isolation, no cross-contamination
- ⚠️ Negative: More complex initial setup, requires Tier 1 MI management and rotation

**Alternatives considered:**

- Single MI with broad permissions → Rejected: security risk, violates least privilege
- Manual project creation → Rejected: doesn't scale, error-prone
- Per-developer MIs → Rejected: too many credentials to manage

**Implementation:** `scripts/deploy-new-site.sh`

---

## AD-002: Batch PRs Instead of Individual Submissions

**Date:** 2026-06-06  
**Status:** Active  
**Context:** Initially created 16 PRs for site.conf/site.sh work across templates

**Decision:** Close all individual PRs and batch into 5 consolidated PRs:

1. site.conf for all docker templates
2. site.sh for all docker templates
3. Infisical outage runbook + references
4. Automated deployment system
5. Branch setup utility

**Rationale:**

- Reduce reviewer burden (5 PRs vs 16)
- Allow iteration and refinement before submission
- Related changes are easier to review together
- Maintains logical grouping of work

**Consequences:**

- ✅ Positive: Easier review process, better quality PRs, less noise
- ⚠️ Negative: Slower initial feedback, requires discipline to complete all work before submitting

**Process:**

1. Complete all related work on feature branches
2. Use `./scripts/setup-feature-branch.sh` to create integrated branches
3. Test thoroughly
4. Submit batched PRs when ready

---

## AD-003: WORK_LOG.md as Local Tracking File

**Date:** 2026-06-06  
**Status:** Active  
**Context:** Need to track detailed work history without cluttering repository

**Decision:** Keep WORK_LOG.md as a local file (gitignored), separate from committed documentation

**Rationale:**

- WORK_LOG.md contains detailed, frequently-updated work history
- STATUS.md provides high-level overview for reviewers (committed)
- DECISIONS.md captures architectural choices (committed)
- Prevents repository bloat from process documentation

**Consequences:**

- ✅ Positive: Clean repository, detailed local tracking, clear separation of concerns
- ⚠️ Negative: Work history not shared across clones, requires manual updates

**File structure:**

- `WORK_LOG.md` — Local, detailed work history (gitignored)
- `STATUS.md` — Committed, high-level project state
- `DECISIONS.md` — Committed, architectural decisions

---

## AD-004: Consolidated Branch Strategy

**Date:** 2026-06-06  
**Status:** Active  
**Context:** Initially created 16 individual branches for each template's site.conf/site.sh work

**Decision:** Consolidate into 5 feature branches that contain all related work:

- `feature/mot-docker-site-conf` — All site.conf implementations
- `feature/mot-docker-site-sh` — All site.sh implementations
- `feature/mot-outage-runbook` — Runbook + all references
- `feature/mot-automated-site-deployment` — Deployment automation
- `feature/mot-branch-setup-tool` — Branch setup utility

**Rationale:**

- Easier to manage and test integrated changes
- Reduces branch proliferation
- Aligns with batched PR strategy (AD-002)
- Preserves all work while simplifying structure

**Consequences:**

- ✅ Positive: Cleaner branch structure, easier integration testing, aligns with PR strategy
- ⚠️ Negative: Larger branches, requires careful merge conflict resolution

**Cleanup:** Deleted 16 redundant individual branches from local, origin, and upstream

---

## AD-005: site.conf Pattern for Configuration Management

**Date:** 2026-06-05  
**Status:** Implemented  
**Context:** Need to manage site-specific configuration without environment variables

**Decision:** Use site.conf file with safe parser (lib.sh) for configuration management

**Implementation:**

- `site.conf` — Key-value configuration file (gitignored in production, committed in templates)
- `lib.sh` — Safe parser that only accepts `KEY=value` format
- `site.sh` — Wrapper script that sources site.conf

**Security considerations:**

- Parser rejects shell metacharacters to prevent code injection
- Configuration values are validated before use
- Sensitive values (secrets) are NOT stored in site.conf

**Consequences:**

- ✅ Positive: No environment variable juggling, configuration is explicit and version-controlled
- ⚠️ Negative: Requires discipline to not commit sensitive values

**Templates affected:** All 7 docker templates

---

## AD-006: site.sh Convenience Wrapper

**Date:** 2026-06-05  
**Status:** Implemented  
**Context:** Operators need to run multiple scripts with IP addresses and configuration

**Decision:** Create site.sh wrapper that auto-detects droplet IP and sources site.conf

**Features:**

- Auto-detects droplet IP from tofu output
- Sources site.conf for configuration
- Provides unified interface: `./site.sh deploy`, `./site.sh backup`, etc.
- Supports manual IP override

**Consequences:**

- ✅ Positive: Simplified operator workflow, no manual IP lookup, consistent interface
- ⚠️ Negative: Additional abstraction layer, requires tofu to be initialized

**Implementation:** `template/site.sh.jinja` (rendered to `site.sh` in each site)

---

## AD-007: Infisical Outage Runbook

**Date:** 2026-06-05  
**Status:** Implemented  
**Context:** Need documented procedures for when Infisical is unavailable

**Decision:** Create comprehensive runbook covering detection, mitigation, and recovery

**Contents:**

- Detection procedures (how to know if Infisical is down)
- Impact assessment (what breaks, what still works)
- Emergency procedures (manual deployment, backup, restore)
- Recovery procedures (when Infisical comes back)
- Prevention strategies (monitoring, redundancy)

**Consequences:**

- ✅ Positive: Clear procedures for outage scenarios, reduces panic, enables quick recovery
- ⚠️ Negative: Requires maintenance as procedures change

**Implementation:** `docs/INFISICAL_OUTAGE_RUNBOOK.md`

---

## AD-008: Automated Deployment with Tiered MI

**Date:** 2026-06-05  
**Status:** Implemented  
**Context:** Manual deployment process is error-prone and time-consuming

**Decision:** Create automated deployment script that handles entire workflow

**Features:**

- 6-phase deployment: validation → Infisical setup → rendering → infrastructure → deployment → reporting
- Tiered MI architecture (see AD-001)
- Dry-run mode for testing
- Auto mode for CI/CD
- Skip flags for partial deployments
- Comprehensive logging

**Consequences:**

- ✅ Positive: Consistent deployments, reduced human error, faster deployment
- ⚠️ Negative: Complex script, requires Tier 1 MI setup

**Implementation:** `scripts/deploy-new-site.sh`

---

## AD-009: Branch Setup Utility

**Date:** 2026-06-06  
**Status:** Implemented  
**Context:** Need to create new branches with integrated completed work

**Decision:** Create utility script that automates branch creation and work integration

**Features:**

- Reads WORK_LOG.md to identify completed work
- Auto-detects task type from branch name
- Suggests appropriate merges based on task type
- Dry-run mode for preview
- Interactive confirmation

**Consequences:**

- ✅ Positive: Consistent branch setup, prevents forgetting to integrate work, saves time
- ⚠️ Negative: Requires WORK_LOG.md to be accurate

**Implementation:** `scripts/setup-feature-branch.sh`

---

## AD-010: Three-Tier Documentation Strategy

**Date:** 2026-06-06  
**Status:** Implemented  
**Context:** Need to balance detailed tracking with clean repository

**Decision:** Use three-tier documentation:

1. **STATUS.md** (committed) — High-level project state for reviewers
2. **WORK_LOG.md** (local, gitignored) — Detailed work history
3. **DECISIONS.md** (committed) — Architectural and process decisions

**Rationale:**

- STATUS.md provides visibility without clutter
- WORK_LOG.md allows detailed tracking without polluting repository
- DECISIONS.md preserves context for future work

**Consequences:**

- ✅ Positive: Clean repository, detailed tracking, clear decision history
- ⚠️ Negative: Requires discipline to maintain all three files

**Implementation:** This document (DECISIONS.md), STATUS.md, WORK_LOG.md

---

## How to Use This Document

**When to add a new decision:**

- Architectural choices (system design, technology selection)
- Process decisions (workflow, tooling, methodology)
- Security decisions (authentication, authorization, data handling)
- Any decision that might be questioned or re-debated in the future

**Decision format:**

```markdown
## AD-XXX: Decision Title

**Date:** YYYY-MM-DD  
**Status:** Implemented | Active | Deprecated | Superseded  
**Context:** Why this decision was needed

**Decision:** What was decided

**Consequences:**
- ✅ Positive: Benefits
- ⚠️ Negative: Drawbacks or risks

**Alternatives considered:**
- Alternative 1 → Why rejected
- Alternative 2 → Why rejected

**Implementation:** Where/how this is implemented
```

**Status meanings:**

- **Implemented:** Decision is in place and working
- **Active:** Decision is current and should be followed
- **Deprecated:** Decision is being phased out
- **Superseded:** Decision has been replaced by a newer one (reference the new AD)

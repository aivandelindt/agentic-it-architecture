# GitHub-Centered Agentic IT Control Plane

**Status:** Draft for review  
**Audience:** IT leadership, security, cloud platform, AI platform owner  
**Date:** 2026-08-26  
**Product snapshot:** GitHub Copilot / Actions behavior as documented on 2026-08-26. Surfaces marked *public preview* are not frozen contracts.

This document defines how a single GitHub Organization becomes the **control plane** for an agentic IT team: agent definitions, skills and plugins, policies, work intake, change history, and approvals. It does **not** make GitHub the runtime for every operation.

Related decisions: [001 — GitHub as control plane](../decisions/001-github-as-control-plane.md), [002 — Agent / skill / workflow split](../decisions/002-agent-skill-workflow-split.md).

---

## 1. Executive recommendation and non-goals

### Recommendation

Use the GitHub Organization as the source of truth for:

- Agent definitions and ownership
- Reusable skills and plugins
- Policies and approval rules
- Work requests (issues) and changes (pull requests)
- Deterministic execution via GitHub Actions
- Evaluation evidence, releases, and documentation
- Audit trails that can be exported to SIEM

Run long-running agents, sensitive integrations, and production mutations in the organization’s cloud environment behind a narrow MCP/API gateway. GitHub governs their source, configuration, deployment, permissions, and change history.

### Non-goals (this architecture)

- Replacing ITSM, CMDB, or monitoring as systems of record
- Giving agents unrestricted shell, SQL, or cloud administrator access
- Autonomously closing incidents, changing IAM, or approving finance
- Treating Copilot AI Controls session UI as long-term compliance evidence
- Implementing org scaffolding, plugins, workflows, or gateway code in this document

---

## 2. Capability map (GitHub product vs internal catalog)

| Capability | Where it lives | Product notes (2026-08-26) |
| --- | --- | --- |
| Org / enterprise custom agents | `.github` or `.github-private` → `/agents` | **Public preview.** Profiles are Markdown with YAML frontmatter. |
| Private agent testing | `.github-private` → `.github/agents` | Collaborators only; move to `/agents` to release org-wide. |
| Skills | Repo paths (`.github/skills`, `.agents/skills`, `.claude/skills`) or user home | **Not org-native.** Distribute via plugins/marketplace or reviewed `gh skill` install (**public preview**). |
| Plugins | Marketplace repo + `plugin.json` | Bundle agents, skills, hooks, MCP/LSP config; enable via Copilot settings. |
| Cloud agent MCP | Repo settings and/or agent profile | Private MCP registries apply to **CLI/IDEs**, not cloud agents. Compensate with org profiles + gateway. |
| Agents secrets | Repo or org “Agents” secrets | **Separate** from Actions, Codespaces, and Dependabot secrets. |
| Cloud agent token | Default repo-scoped `GITHUB_TOKEN` | Do not assume org-wide package or cross-repo access without explicit grants. |
| Firewall | Cloud agent network controls | Does **not** constrain MCP or `copilot-setup-steps.yml`. Protect those files as permission-equivalent. |
| AI Controls (enterprise) | Enterprise AI Controls UI / APIs | Session list is short-lived (docs: last 24 hours). Stream audit logs to SIEM. |
| IDE / local agents | VS Code and local clients | Outside GitHub AI Controls. |
| Third-party coding agents | Separate enterprise policies | Disabling Copilot cloud agent does **not** disable partner agents; configure independently. |
| Internal catalog metadata | `catalog/*.yaml` in governance repos | **Our** metadata (owner, risk tier, eval suite). Not a GitHub API object. |

**Portability principle:** If org-level custom agents or `gh skill` change, the operating model still holds because **workflows, pull requests, environments, and the MCP gateway** remain the enforcement layer.

**References (product facts):**

- [Preparing custom agents for an organization](https://docs.github.com/en/copilot/how-tos/administer-copilot/manage-for-organization/prepare-for-custom-agents)
- [Testing and releasing custom agents](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/test-custom-agents)
- [About agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- [About plugins](https://docs.github.com/en/enterprise-cloud@latest/copilot/concepts/agents/about-plugins)
- [Agent management for enterprises](https://docs.github.com/en/copilot/concepts/agents/enterprise-management)
- [Giving cloud agent access to resources](https://docs.github.com/en/copilot/tutorials/cloud-agent/give-access-to-resources)

---

## 3. Control-plane architecture and trust boundaries

Editorial diagram: [github-agentic-it-control-plane.html](./github-agentic-it-control-plane.html) — GitHub governs source and approvals; only GitHub Actions may cross the MCP/API gateway; direct agent-to-system calls stop at the trust boundary.

```text
Humans / IT systems
        |
        v
Issues, PRs, Projects, Copilot, CLI
        |
        v
GitHub Organization (control plane)
  agents | skills/plugins | policies | evals | workflows | audit
        |
   +----+----+----------------+
   v         v                v
Copilot    GitHub Actions   Cloud runtime
cloud      (deterministic)  (sensitive / long-running)
agents
        |
        v
Approved MCP/API gateway
        |
Service catalog, monitoring, ITSM, cloud APIs, chat
```

### Trust boundaries

1. **Human / agent boundary** — Agents draft and recommend; humans approve Tier 3+ and externally visible actions.
2. **Proposal / execution boundary** — Agents propose; workflows execute with least privilege, timeouts, and approvals.
3. **GitHub / enterprise systems boundary** — Only the MCP/API gateway talks to ITSM, monitoring, CMDB, and cloud control planes with narrow tools.
4. **Data classification boundary** — Agents and MCP tools are capped at a maximum classification; restricted HR/legal/finance repos stay out of scope.
5. **IDE / cloud boundary** — Local IDE agents are policy-controlled separately from org cloud agents.

---

## 4. Organization repository topology

### Target shape (documented; not created in this pass)

```text
your-github-organization/
├── .github-private/          # Org agents + governance
├── ai-agent-marketplace/     # Approved plugins and skills
├── ai-workflows/             # Reusable Actions, OIDC, environments
├── ai-evaluations/           # Quality and safety suites
├── mcp-gateway/              # Gateway source + infra (runs in cloud)
└── agentic-it-docs/          # Architecture, runbooks, catalog
```

### Repository responsibilities

| Repository | Responsibility |
| --- | --- |
| `.github-private` | Org-wide agent profiles (`/agents`), private testing (`.github/agents`), policies, CODEOWNERS, internal catalog metadata |
| `ai-agent-marketplace` | Versioned plugins (`marketplace.json`), skill source, security review evidence, deprecation notes |
| `ai-workflows` | Deterministic reusable workflows and custom actions; input validation; environment protections |
| `ai-evaluations` | Golden cases, permission boundaries, prompt-injection, refusal, regression, cost/latency thresholds |
| `mcp-gateway` | Tool schemas, authn/authz, rate limits, data filtering, audit, kill switch (deployed to cloud) |
| `agentic-it-docs` | Architecture, runbooks, onboarding, decisions, service-catalog notes |

### Leaner bootstrap (recommended for Phase 1–2)

Do not block security review on six new repositories. A practical bootstrap:

1. `.github-private` — agents + policies (required)
2. `agentic-it-platform` — marketplace plugins, reusable workflows, and evaluation suites in one monorepo initially
3. `mcp-gateway` — only when the first external write tool is approved
4. Split marketplace / workflows / evaluations later when ownership or release cadence diverges

This docs repository can seed `agentic-it-docs` or be adopted as that repo.

### Protection intent (CODEOWNERS and rulesets)

Apply organization rulesets to control-plane and production infrastructure repos:

- Pull requests required; no force pushes; no branch deletion; restricted bypass
- CODEOWNERS for `/agents`, `/policies`, plugin manifests, MCP config, `copilot-setup-steps.yml`, workflow files
- Security-owner review for tool, permission, or MCP changes (treat as permission changes)
- Required status checks including evaluation suite and secret scanning where applicable

---

## 5. Agent / skill / plugin / workflow contracts

### Agent

A specialized team role. Defines purpose, instructions, constraints, skills, approved tools/MCP servers, read/write scope, required human approvals, expected outputs, operational owner, and risk classification.

**GitHub shape:** Markdown profile with YAML frontmatter (org examples use named profiles such as `agent.md`; plugin packages use `*.agent.md`). Do not invent a third file format.

**Internal catalog shape:** Separate YAML metadata (owner, risk tier, eval suite, review cadence). Not a GitHub API object.

### Skill

A small, reusable capability (`SKILL.md` plus optional scripts, references, assets). Loaded on demand for specialized tasks (classify a ticket, draft a postmortem, review a Terraform plan).

Skills are **repository- or user-scoped**. Central distribution uses plugins/marketplace and/or reviewed `gh skill` install. Third-party skills require security review before approval (prompt injection and malicious scripts are real risks).

### Plugin

A versioned, installable package of agents, skills, hooks, and MCP/LSP configuration. Preferred mechanism for sharing a standard IT capability set across repositories. Enable via repository Copilot settings (`enabledPlugins`) and, under an enterprise, managed plugin standards.

### Workflow

Deterministic automation with defined inputs, permissions, validation, approvals, timeouts, concurrency limits, audit, and rollback. Examples: infrastructure plan, approved deployment, publish daily ops report, create change ticket.

**Contract:** Agents normally **request workflows**; they do not receive unrestricted shell or cloud access.

### Accountability line

```text
Agent decides what should be proposed.
Skill explains how to perform a specialized task.
Workflow validates and performs an approved action.
Human remains accountable for high-impact decisions.
GitHub records the complete change and approval history.
```

---

## 6. Risk model and default deny policy

| Tier | Description | Examples | Human approval |
| --- | --- | --- | --- |
| **0** | Read-only information | Search runbooks, summarize issues | Normally not required |
| **1** | Creates drafts | Draft issue, report, PR, incident update | Before publishing sensitive output |
| **2** | Writes to non-production systems | Create ticket, update docs, open PR | Policy-dependent |
| **3** | Controlled operational changes | Deploy via workflow, restart service | Mandatory protected approval |
| **4** | High-impact / prohibited autonomous | IAM escalation, production deletion, financial approval | Human-only or dual approval |

### Default policy

1. Start every agent as **read-only or draft-only**.
2. Grant write permissions only after evaluation and system-owner approval.
3. Never give agents permanent administrator credentials.
4. Production changes follow the same PR, CI, approval, and deployment path as human changes.
5. High-risk decisions remain human-owned.

---

## 7. Initial portfolio and daily operating model

### Initial agents (read / draft first)

| Agent | Purpose | Initial permissions |
| --- | --- | --- |
| **IT Intake** | Summarize, classify, find duplicates, request missing info | Read issues/catalog; draft labels/comments; no close; no infra |
| **Daily Operations** | Prioritized daily briefing from ops signals | Read-only integrations; publish draft briefing |
| **Incident Assistant** | Timeline, runbook, drafts for commander | No resolve declaration; no unapproved external comms; no direct prod failover |
| **Knowledge Curator** | Runbook/FAQ drafts from resolved work | Docs PRs require owner review; no secrets; no silent history rewrite |

**Cloud Change Planner** is Phase 5 only: draft PRs, plans, and rollback notes — **never** direct deploy.

### Associated starter skills (catalog intent)

`summarize-work-item`, `classify-it-request`, `identify-service-owner`, `find-runbook`, `draft-operational-update`, `create-incident-timeline`, `draft-postmortem`, `draft-runbook-update`, `review-terraform-plan`, `prepare-change-record`.

### Daily operating model

**Start of day:** Daily Operations Agent publishes a prioritized briefing → team lead confirms priorities → assign humans or agents.

**During the day:** Issue forms / integrations → Intake Agent enriches → low-risk research to agents → code/config via PRs → ops actions via approved workflows → humans approve high-impact or external actions.

**Incident:** Monitoring opens/links incident issue → Incident Assistant gathers context → commander decides → approved workflows remediate → agent maintains timeline and drafts updates → postmortem and runbook drafts after resolution.

**End of day:** Outstanding/blocked summary → decisions recorded → Knowledge Curator proposes doc updates.

---

## 8. Security architecture

### Identity and credentials (preference order)

1. GitHub `GITHUB_TOKEN` with explicit minimal permissions
2. GitHub Apps with narrow installation permissions
3. Cloud OIDC federation (short-lived cloud credentials; constrain trust to approved reusable workflows where possible)
4. Short-lived external system tokens
5. Long-lived secrets only when no alternative exists

Design each integration for its execution environment. Agents secrets are not Actions secrets.

### MCP / API gateway controls

Prefer narrow tools (`get_active_incidents`, `create_change_request`, `restart_service` with change id) over unbounded tools (`execute_shell`, `run_sql`, `call_any_url`, `perform_cloud_action`).

For each tool define: approved agents and repositories, read/write scope, data classification, input schema, max request size, allowed environments, approval requirement, rate limit, audit requirements, credential identity, emergency-disable procedure.

Compensate for the cloud-agent MCP registry gap with:

- Org-level custom agent profiles (not ad-hoc repo MCP where avoidable)
- Rulesets/CODEOWNERS on MCP and setup config files
- Gateway-side authorization and kill switch

### Production protection

Use GitHub Environments for production workflows: required reviewers, prevent self-review, restricted deployment branches, environment-specific credentials, change-window validation where needed.

### Emergency controls (document and test)

Disable Copilot cloud agent and automated agent execution; disable scheduled automations; revoke MCP credentials / individual tools; revoke cloud OIDC role trust; stop self-hosted runners; disable plugin or skill version; block compromised repository; roll agents back to previous release. Configure third-party coding agent policies separately.

---

## 9. Lifecycle, evaluation gates, and catalog metadata

```text
Proposal → Design + risk classification → Implementation
  → Automated evaluations → Security + system-owner review
  → Read-only pilot → Draft/write pilot → Production release
  → Monitoring + periodic recertification → Deprecation
```

Every production agent requires: golden and failure cases; permission-boundary, prompt-injection, sensitive-data, and destructive-refusal tests; output-quality checks; cost and latency thresholds.

### Example internal catalog metadata (not a GitHub API object)

```yaml
name: cloud-change-planner
owner: cloud-platform-team
business_owner: head-of-infrastructure
risk_tier: 2
purpose: Prepare infrastructure-as-code changes and deployment plans.
allowed_repositories:
  - infrastructure-*
  - platform-*
allowed_tools:
  - github-read
  - github-create-pull-request
  - terraform-plan
  - service-catalog-read
prohibited_actions:
  - direct-production-deployment
  - iam-privilege-change
  - resource-deletion
human_approval:
  pull_request: required
  production_execution: required
  external_communication: required
data_classification:
  maximum: internal
evaluation_suite:
  - functional/cloud-change
  - security/permission-boundaries
  - security/prompt-injection
release:
  version: 1.0.0
  reviewed_on: 2026-08-26
  review_frequency_days: 90
```

Keep the actual Copilot agent profile in the GitHub-supported Markdown format.

---

## 10. RACI / named-owner rule

| Role | Responsibility |
| --- | --- |
| **AI Platform Owner** | Architecture, standards, catalog, roadmap |
| **Agent Owner** | Agent quality, instructions, metrics, maintenance |
| **Skill Owner** | Accuracy and lifecycle of a capability |
| **System Owner** | Approves access to ITSM, monitoring, cloud, and other systems |
| **Security Team** | Threat modeling, permission review, incident response for agent misuse |
| **Cloud Platform Team** | Runners, OIDC, environments, deployment workflows |
| **Service Owner** | Approves agent use for a specific IT service |
| **Human Approver** | Accountable for high-impact decisions and operations |
| **Audit / Compliance** | Retention, evidence, policy, periodic review |

**Rule:** No agent is deployed without a named human owner.

---

## 11. Observability and metrics

Collect by agent, skill, repository, team, and task type. Export audit and telemetry to the organization’s SIEM / observability platform; do not rely only on short-lived AI Controls UI views.

### Operational

Tasks delegated; successful completion; average duration; human wait time; failed tool calls; retries; cost per successful task; availability.

### Quality

Output acceptance rate; major-rework rate; PR merge rate; incorrect classification; incident-summary correction rate; documentation accuracy; regression pass rate.

### Safety

Blocked prohibited operations; permission-denied attempts; secret exposure; prompt-injection detections; unauthorized tool requests; emergency shutdowns; policy exceptions and bypasses.

### Business

MTTA / MTTR; change lead time; deployment failure rate; time on repetitive work; aging ticket reduction; runbook coverage; estimated human hours saved.

---

## 12. Phased roadmap

### Phase 1 — Foundation (weeks 1–2)

Confirm licensing; appoint AI Platform Owner and governance; define risk tiers and approved/prohibited use cases; inventory systems and data classifications; select two or three pilot repos; set success metrics. Scope: read-only reporting, issue classification, documentation drafting. No production write access.

### Phase 2 — GitHub platform (weeks 3–4)

Create `.github-private` and lean platform repo(s); teams and CODEOWNERS; org rulesets; secret scanning and push protection; audit export; OIDC trust; protected environments; agent/skill templates; emergency-disable procedure.

**Exit:** Agent-profile changes require review; skill/plugin releases are versioned; cloud deploy uses short-lived credentials; audit retained outside GitHub where required.

### Phase 3 — Low-risk pilot (weeks 5–8)

IT Intake, Daily Operations, Knowledge Curator; one ops team; two or three repos; read-only external integrations; draft-only outputs.

**Suggested exit (tune locally):** majority of pilot outputs accepted with minor edits; no unauthorized tool calls; no sensitive-data exposure; measurable reduction in repetitive work; positive owner feedback.

### Phase 4 — Operational integration (weeks 9–12)

Incident Assistant; monitoring and service-catalog read; ITSM create-ticket only; chat notifications with restricted publishing; evaluation automation; cost/latency dashboards. Narrow write only.

### Phase 5 — Controlled cloud changes (months 4–6)

Cloud Change Planner; IaC generation and plan review; policy-as-code; protected deployment workflows; attestations where used; verification and rollback preparation. Production still requires human approval, change record, code-owner review, environment approval, short-lived cloud identity, and post-deploy verification.

---

## 13. First-release contents and explicit prohibitions

### Include

- Org agents: `it-intake`, `daily-operations`, `incident-assistant`, `knowledge-curator`
- Initial skills listed in §7
- Integrations: GitHub Issues/PRs/Actions; monitoring and service catalog **read-only**; ITSM **create-ticket only**; chat **restricted publishing**

### Prohibit

- Direct production changes by agents
- Unrestricted shell execution
- Broad cloud administrator roles
- Autonomous IAM changes
- Autonomous ticket closure
- Customer/executive communication without approval
- Access to restricted HR, legal, or financial repositories

---

## 14. Open decisions

Resolve before or during Phase 1–2:

| Decision | Options / notes |
| --- | --- |
| Enterprise vs single org | Spec is valid for one org; Enterprise Cloud + AI Controls, `managed-settings.json`, audit streaming, and enterprise plugin standards recommended if under an enterprise |
| ITSM product | e.g. ServiceNow — gateway tool shapes depend on it |
| Chat / notification channel | e.g. Teams or Slack — restricted publishing only initially |
| IaC toolchain | e.g. Terraform, Bicep, CloudFormation, Pulumi — Cloud Change Planner skills follow this |
| Runner topology | GitHub-hosted vs self-hosted (especially for private network / package access) |
| Repo bootstrap | Six-repo target vs lean `agentic-it-platform` monorepo first |
| Success thresholds | Replace Phase 3’s qualitative “majority accepted with minor edits” exit with org-specific numeric targets |

---

## Document control

| Field | Value |
| --- | --- |
| Owner | AI Platform Owner (to be named in Phase 1) |
| Reviewers | Security, Cloud Platform, IT Operations |
| Next review | After Phase 1 decisions, or within 90 days |
| Implementation status | Spec only — no org scaffolding in this repository yet |

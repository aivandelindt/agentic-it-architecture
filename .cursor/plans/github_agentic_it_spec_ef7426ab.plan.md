---
name: GitHub Agentic IT Spec
overview: Write a socializable architecture specification that treats one GitHub Organization as the control plane for an agentic IT team. No org scaffolding yet—this is the design document for IT, security, and platform owners.
todos:
  - id: create-docs-repo
    content: Create ~/Projects/agentic-it-architecture, init git, move workspace root before writing files
    status: completed
  - id: write-control-plane-spec
    content: Write docs/architecture/github-agentic-it-control-plane.md from the approved outline, including GitHub product corrections and preview callouts
    status: completed
  - id: write-adrs-and-readme
    content: Add README plus ADRs for GitHub-as-control-plane and agent/skill/workflow split
    status: completed
  - id: spec-self-review
    content: Scan for TBDs, contradictions, and over-scope; then ask for human review before any org scaffolding
    status: completed
isProject: false
---

# GitHub-Centered Agentic IT Architecture Spec

Using brainstorming to turn the drafted operating model into a reviewable spec, not a repo rollout.

## Deliverable

After approval, create a small docs repo at [`/Users/dvandelindt/Projects/agentic-it-architecture`](/Users/dvandelindt/Projects/agentic-it-architecture), move the workspace there, and write one architecture spec plus a short decision log.

Primary file:

- [`docs/architecture/github-agentic-it-control-plane.md`](/Users/dvandelindt/Projects/agentic-it-architecture/docs/architecture/github-agentic-it-control-plane.md)

Supporting files:

- [`README.md`](/Users/dvandelindt/Projects/agentic-it-architecture/README.md) — purpose, audience, how to review
- [`docs/decisions/001-github-as-control-plane.md`](/Users/dvandelindt/Projects/agentic-it-architecture/docs/decisions/001-github-as-control-plane.md)
- [`docs/decisions/002-agent-skill-workflow-split.md`](/Users/dvandelindt/Projects/agentic-it-architecture/docs/decisions/002-agent-skill-workflow-split.md)

Audience: IT leadership, security, cloud platform, and the named AI platform owner. Keep language operational, cite GitHub product behavior as of 26 Aug 2026, and mark public-preview surfaces so reviewers do not treat them as frozen contracts.

Out of scope for this pass: creating `.github-private`, plugins, workflows, evaluations, or MCP gateway code.

## Design to lock in the spec

**GitHub is the control plane, not the runtime.** Issues, PRs, agent profiles, skills/plugins, reusable workflows, approvals, and audit live in GitHub. Long-running orchestration, sensitive integrations, and production mutations run in the cloud behind a narrow MCP/API gateway.

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

**Four primitives, one accountability line:**

- Agent: specialized role (instructions, tools, risk tier, owner)
- Skill: on-demand task procedure (`SKILL.md` + optional scripts/references)
- Plugin: versioned bundle of agents/skills/hooks/MCP config for distribution
- Workflow: deterministic, least-privilege action with approvals

Agents propose. Skills teach. Workflows execute. Humans own high-impact decisions. GitHub keeps the change history.

**Target org topology (documented, not created):**

- `.github-private` — org agents and governance. Test in `.github/agents`, release to `/agents`.
- `ai-agent-marketplace` — approved plugins/skills (`marketplace.json`, versioned plugins)
- `ai-workflows` — reusable Actions, OIDC deploy, protected environments
- `ai-evaluations` — functional, permission, injection, and refusal suites
- `mcp-gateway` — tool schemas, authz, audit, kill switch (runs in cloud)
- `agentic-it-docs` — runbooks, catalog, onboarding (this spec seeds it)

Phase 1 of the *future* rollout can collapse marketplace + evaluations into fewer repos; the spec will recommend the target shape and a leaner bootstrap so security does not block on six new repositories.

**Initial agents (read/draft first):** IT Intake, Daily Operations, Incident Assistant, Knowledge Curator. Cloud Change Planner is documented as phase 5 only (draft PRs + plan, never direct deploy).

**Risk tiers 0–4** stay as drafted: start read-only/draft-only; production mutations only through protected workflows; IAM/deletion/financial approval remain human-only.

## Corrections vs the pasted draft

These will be explicit in the spec so reviewers trust the GitHub mapping:

- **Custom agents are public preview** and can change. Keep profiles portable and version-controlled. Source: [prepare-for-custom-agents](https://docs.github.com/en/copilot/how-tos/administer-copilot/manage-for-organization/prepare-for-custom-agents).
- **Test vs release paths are GitHub-native:** `.github/agents` in `.github-private` is private to repo collaborators; moving the profile to `/agents` publishes org-wide. Source: [test-custom-agents](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/test-custom-agents).
- **Agent filenames:** org profiles are Markdown with YAML frontmatter (GitHub’s examples use `agent.md` / named profiles). Plugin packages use `*.agent.md`. The spec will not invent a third format; catalog YAML stays *internal governance metadata*, not a GitHub API object.
- **Skills are repo- or user-scoped**, not org-native. Central distribution is plugins + marketplace (and/or reviewed `gh skill` install). `gh skill` is public preview.
- **Private MCP registries apply to Copilot CLI/IDEs, not cloud agents.** Cloud agent MCP is configured in repository settings and/or custom agent profiles. Treat that as a control-plane gap and compensate with org agent profiles, rulesets on config files, and a gateway. Source: [enterprise-management](https://docs.github.com/en/copilot/concepts/agents/enterprise-management).
- **Agents secrets ≠ Actions/Codespaces/Dependabot secrets.** Integrations must be designed per execution environment. Cloud agent `GITHUB_TOKEN` is repo-scoped by default. Source: [give-access-to-resources](https://docs.github.com/en/copilot/tutorials/cloud-agent/give-access-to-resources).
- **Firewall does not constrain MCP or `copilot-setup-steps.yml`.** Those files are permission-equivalent; protect them with CODEOWNERS/rulesets.
- **IDE/local agents are outside GitHub AI Controls.** VS Code agent mode is an IDE policy. Third-party coding agents (Claude, Codex, etc.) have **separate** enablement policies from Copilot cloud agent.
- **AI Controls session views are short-lived** (docs: last 24 hours). Stream enterprise/org audit logs to SIEM; do not treat the UI as the record.
- **Enterprise add-on, not required for the single-org design:** GitHub Enterprise Cloud + Copilot enterprise AI Controls, `managed-settings.json`, audit streaming, and enterprise plugin standards are recommended if the org later sits under an enterprise. The spec stays valid for one organization.

## Spec outline

The main document will follow this structure (tight prose, diagrams, no vendor lock to a specific ITSM/cloud beyond examples):

1. Executive recommendation and non-goals
2. Capability map: GitHub product vs internal catalog (GA vs preview)
3. Control-plane architecture and trust boundaries
4. Organization repository topology and CODEOWNERS/ruleset intent
5. Agent / skill / plugin / workflow contracts
6. Risk model and default deny policy
7. Initial portfolio and daily operating model
8. Security architecture: identity, MCP, secrets, environments, OIDC, emergency stop
9. Lifecycle, evaluation gates, and catalog metadata
10. RACI / named-owner rule
11. Observability and metrics (operational, quality, safety, business)
12. Phased roadmap (foundation → platform → read-only pilot → ITSM/monitoring writes → controlled cloud change)
13. First-release contents and explicit prohibitions
14. Open decisions (enterprise vs org, ITSM, chat, IaC tool, runner topology)

Keep integrations generic: “ITSM”, “monitoring”, “service catalog”, “chat”. Use ServiceNow/Teams/Terraform only as examples.

## Writing constraints

- Portable: if org-level custom agents or `gh skill` change, the operating model still holds because workflows, PRs, and the gateway remain the enforcement layer.
- No implementation of agents, skills, or Actions in this pass.
- Cite official GitHub docs for product facts; keep recommendations clearly labeled as ours.
- After the spec is written, do a self-review for placeholders, contradictions, and scope creep before asking you to review the files.

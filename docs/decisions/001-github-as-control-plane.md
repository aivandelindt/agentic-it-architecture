# ADR 001 — GitHub Organization as control plane

**Status:** Accepted  
**Date:** 2026-08-26  
**Deciders:** Architecture draft for IT / security / platform review

## Context

The IT organization wants a central place to define AI agents, share skills, govern permissions, intake work, approve changes, and retain evidence. Options include a custom agent platform, an ITSM-centric bot layer, or GitHub as the primary control surface with cloud runtimes for sensitive execution.

## Decision

Use a **single GitHub Organization as the control plane and source of truth** for agent definitions, skills/plugins, policies, issue intake, pull-request change history, reusable Actions workflows, evaluations, and audit export.

Do **not** use GitHub as the runtime for every operation. Long-running orchestration, sensitive integrations, and production mutations run in the organization’s cloud behind a narrow MCP/API gateway. GitHub governs their source code, configuration, deployment, permissions, and changes.

## Consequences

### Positive

- Reuses existing developer change controls (PR, CODEOWNERS, rulesets, environments, OIDC).
- Aligns agent work with the same evidence path as human infrastructure changes.
- Supports org-level custom agents (public preview) and plugin distribution when those features are enabled.
- Keeps enforcement portable if Copilot agent/skill product surfaces change: workflows, PRs, and the gateway remain the hard boundary.

### Negative / trade-offs

- Skills are not org-native; distribution needs plugins/marketplace or reviewed install automation.
- Cloud-agent MCP is not governed by the same private MCP registries as CLI/IDEs; compensate with org agent profiles, config-file protection, and a gateway.
- Agents secrets, Actions secrets, and IDE agents are separate control planes and must be designed explicitly.
- Enterprise AI Controls (session UI, managed settings, audit streaming) are recommended add-ons when the org sits under GitHub Enterprise Cloud; the single-org model remains valid without them but with thinner central visibility.

## Alternatives considered

1. **Custom agent runtime as system of record** — Stronger for long-running jobs, weaker for unified change/audit with existing IaC and Actions practices.
2. **ITSM-only bots** — Good for ticket workflows; poor for code, IaC, and PR-based approval of infrastructure.
3. **Fully autonomous cloud agents with broad credentials** — Rejected on security and accountability grounds.

## Related

- [Control-plane architecture](../architecture/github-agentic-it-control-plane.md)
- [ADR 002 — Agent / skill / workflow split](002-agent-skill-workflow-split.md)

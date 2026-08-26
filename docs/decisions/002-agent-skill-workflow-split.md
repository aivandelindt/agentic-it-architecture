# ADR 002 — Agent / skill / plugin / workflow split

**Status:** Accepted  
**Date:** 2026-08-26  
**Deciders:** Architecture draft for IT / security / platform review

## Context

Agentic IT work mixes judgment (triage, summarization, planning) with deterministic operations (deploy, restart, rotate, ticket create). Collapsing everything into “the agent can do it” creates permission sprawl, weak audit, and unclear human accountability.

GitHub Copilot exposes overlapping customization surfaces: custom agents, skills (`SKILL.md`), plugins, MCP, and Actions workflows. The organization needs a clear contract for which surface owns which responsibility.

## Decision

Adopt four primitives with one accountability line:

| Primitive | Role |
| --- | --- |
| **Agent** | Specialized team role: instructions, tools, risk tier, owner, expected outputs |
| **Skill** | On-demand procedure for a specialized task (`SKILL.md` + optional scripts/references) |
| **Plugin** | Versioned distribution unit for agents, skills, hooks, and MCP config |
| **Workflow** | Deterministic, least-privilege action with validation, approvals, and audit |

**Accountability line:**

```text
Agent decides what should be proposed.
Skill explains how to perform a specialized task.
Workflow validates and performs an approved action.
Human remains accountable for high-impact decisions.
GitHub records the complete change and approval history.
```

Agents normally **request workflows**; they do not receive unrestricted shell or cloud access. Internal catalog YAML (owner, risk tier, eval suite) is governance metadata only—not a substitute for GitHub agent profile format.

## Consequences

### Positive

- Separates probabilistic reasoning from privileged execution.
- Matches GitHub product shapes without inventing a parallel agent file format.
- Enables risk tiers: start read-only/draft; promote writes only after evaluation.
- Plugins give a reviewable release unit for org-standard IT capabilities.

### Negative / trade-offs

- More moving parts than a single “super-agent” prompt.
- Skills must be distributed deliberately (plugins / marketplace / reviewed install).
- Workflow authoring and environment protection remain mandatory before any Tier 3 action.
- Requires named owners for agents and skills (RACI), not only platform ownership.

## Alternatives considered

1. **Agent with broad MCP tools, no workflow gate** — Faster demos; unacceptable for production IT.
2. **Workflows only, no agents** — Strong control, weak coverage of triage, briefing, and drafting work.
3. **Skills-only customization** — Insufficient for role-level tool and approval constraints.

## Related

- [Control-plane architecture](../architecture/github-agentic-it-control-plane.md)
- [ADR 001 — GitHub as control plane](001-github-as-control-plane.md)

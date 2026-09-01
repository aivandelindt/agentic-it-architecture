# Agentic IT Architecture

Architecture documentation for running an agentic IT team with a **GitHub Organization as the control plane**.

This repository is a **spec and decision log**, not an implementation of agents, skills, Actions, or an MCP gateway.

## Audience

- IT leadership
- Security
- Cloud platform
- Named AI platform owner

## Start here

1. [GitHub-Centered Agentic IT Control Plane](docs/architecture/github-agentic-it-control-plane.md) — full architecture
2. [IT Cloud Team — Agentic AI roadmap](docs/roadmaps/it-cloud-team-ai-roadmap.md) — Agentic Enterprise 2028 applied (18-month autonomy ladder)
3. [ADR 001 — GitHub as control plane](docs/decisions/001-github-as-control-plane.md)
4. [ADR 002 — Agent / skill / workflow split](docs/decisions/002-agent-skill-workflow-split.md)

## How to review

1. Read the control-plane spec end to end (about one sitting for security and platform owners).
2. Check §2 (capability map) and §8 (security) against your GitHub/Copilot licensing and enterprise posture.
3. Resolve open decisions in §14 before scaffolding org repositories.
4. Comment on the documents or open issues in this repo; do not treat public-preview GitHub surfaces as frozen APIs.

## Out of scope (this pass)

Creating `.github-private`, plugin marketplaces, reusable workflows, evaluation suites, or MCP gateway code. Those belong in a later implementation plan after this spec is approved.

## Product snapshot

Documented against GitHub Copilot and Actions behavior as of **2026-08-26**. Preview features are called out in the architecture doc.

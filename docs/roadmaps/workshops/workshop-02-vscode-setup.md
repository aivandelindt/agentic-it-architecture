# Workshop 2 — VS Code setup with GitHub Copilot & NL ITS Cloud AI Marketplace

**Audience:** IT Cloud team engineers  
**Duration:** ~90 minutes  
**Prerequisites:** GitHub Copilot license (Deloitte-Netherlands), VS Code 1.99+

**Visual edition:** [workshop-02-vscode-setup.html](./workshop-02-vscode-setup.html)  
**Parent guide:** [NL ITS Cloud Copilot marketplace](../nl-its-cloud-copilot-marketplace.md)

---

## Learning objectives

By the end of this workshop, participants can:

1. Explain what a GitHub Copilot **plugin** is and what it contains
2. Register the **Deloitte-Netherlands/nl-its-cloud-ai-marketplace** in VS Code
3. Install project-required plugins from the org marketplace
4. Declare `enabledPlugins` in a repository for team consistency

---

## Part 1 — GitHub Copilot plugins

Plugins are installable packages that extend Copilot with reusable **agents**, **skills**, **hooks**, and **integrations**. They distribute custom Copilot functionality across Copilot CLI, Copilot cloud agent, and the GitHub Copilot app in VS Code.

### What is a plugin?

- A **distributable package** that extends Copilot's functionality
- A **bundle of components** in a single installable unit

### What plugins contain

| Component | Description | Location |
| --- | --- | --- |
| **Custom agents** | Specialized AI assistants | `agents/*.agent.md` |
| **Skills** | Discrete callable capabilities | `skills/<name>/SKILL.md` |
| **Hooks** | Event handlers that intercept agent behavior | `hooks.json` or `hooks/` |
| **MCP server config** | Model Context Protocol integrations | `.mcp.json` or `.github/mcp.json` |
| **LSP server config** | Language Server Protocol integrations | `lsp.json` or `.github/lsp.json` |

### Plugin directory structure

```text
nl-its-cloud-ai-plugin/
├── plugin.json           # Required manifest
├── agents/               # Custom agents (optional)
│   └── helper.agent.md
├── skills/               # Skills (optional)
│   └── deploy/
│       └── SKILL.md
├── hooks.json            # Hook configuration (optional)
├── .mcp.json             # MCP server config (optional)
└── lsp.json              # LSP server config (optional)
```

### Why use plugins?

- **Reusability** across projects
- **Team standardization** of Copilot configuration
- **Share domain expertise** (Terraform, Kubernetes, Deloitte diagrams, etc.)
- **Encapsulate** complex MCP server setups

### Plugins vs manual configuration

| Feature | Manual configuration | Plugin |
| --- | --- | --- |
| Scope | Single repository | Any project |
| Sharing | Manual copy/paste | Install command or `enabledPlugins` |
| Versioning | Git history | Marketplace versions |
| Discovery | Searching repositories | Marketplace browsing |

---

## Part 2 — Plugin marketplaces

A **marketplace** is a registry of plugins — like an app store for Copilot extensions. Ours is:

**`Deloitte-Netherlands/nl-its-cloud-ai-marketplace`**

Defined by `marketplace.json` at the repository root, listing versioned plugins with name, description, version, and source path.

```json
{
  "name": "nl-its-cloud-ai-marketplace",
  "plugins": [
    {
      "name": "agentic-infra-ops",
      "description": "End-to-end infrastructure delivery with approval gates",
      "version": "0.1.0",
      "source": "./plugins/agentic-infra-ops"
    }
  ]
}
```

### Where to get plugins

| Source | Our policy |
| --- | --- |
| **Org marketplace** | `nl-its-cloud-ai-marketplace` — **sanctioned path** |
| Public marketplaces (e.g. `github/copilot-plugins`) | Only if listed in our marketplace after compliance review |
| Local path / ad-hoc repo | Development only — not for production use |

---

## Part 3 — VS Code setup (hands-on)

### Step 1 — Prerequisites

| Requirement | Check |
| --- | --- |
| GitHub Copilot license (org-assigned) | Settings → Copilot shows active |
| VS Code 1.99+ | Help → About |
| Extensions: **GitHub Copilot** + **GitHub Copilot Chat** | Extensions panel |
| `gh` CLI authenticated to Deloitte-Netherlands | `gh auth status` |
| Read access to `nl-its-cloud-ai-marketplace` | Open repo in browser |

### Step 2 — Register the organization marketplace

**Copilot Chat (recommended):**

```
/plugin marketplace add Deloitte-Netherlands/nl-its-cloud-ai-marketplace
```

Verify:

```
/plugin marketplace list
```

**Copilot CLI alternative:**

```bash
copilot plugin marketplace add Deloitte-Netherlands/nl-its-cloud-ai-marketplace
copilot plugin marketplace list
```

### Step 3 — Install plugins for your project

```bash
# Infrastructure project
copilot plugin install agentic-infra-ops@nl-its-cloud-ai-marketplace
copilot plugin install servicenow-ops@nl-its-cloud-ai-marketplace

# Documentation / deliverables
copilot plugin install documentation-writer@nl-its-cloud-ai-marketplace
copilot plugin install diagram-design@nl-its-cloud-ai-marketplace
copilot plugin install presentation-design@nl-its-cloud-ai-marketplace
```

In Copilot Chat:

```
/plugin install agentic-infra-ops@nl-its-cloud-ai-marketplace
```

### Step 4 — Verify installation

1. Open **Copilot Chat** → agent picker — plugin agents should appear (e.g. `infra-delivery-orchestrator`)
2. Run `/plugin marketplace browse nl-its-cloud-ai-marketplace` — see full catalog
3. Invoke a skill by name or let the agent load it on demand

### Step 5 — Declare plugins in your repository

Add to `.github/copilot/settings.json` (or repository Copilot settings):

```json
{
  "enabledPlugins": {
    "agentic-infra-ops@nl-its-cloud-ai-marketplace": true,
    "servicenow-ops@nl-its-cloud-ai-marketplace": true
  },
  "extraKnownMarketplaces": {
    "nl-its-cloud-ai-marketplace": {
      "source": {
        "source": "github",
        "repo": "Deloitte-Netherlands/nl-its-cloud-ai-marketplace"
      }
    }
  }
}
```

Document in the project README which plugins are required and the install command.

### Step 6 — Keep plugins current

```bash
copilot plugin marketplace update nl-its-cloud-ai-marketplace
copilot plugin update agentic-infra-ops@nl-its-cloud-ai-marketplace
```

When the org marketplace has **Sync automatically** enabled (Organization settings → Plugins), VS Code refreshes on session start after marketplace merges.

---

## Part 4 — Install paths by client

| Client | How to install |
| --- | --- |
| **VS Code / Copilot Chat** | `/plugin marketplace add` then `/plugin install` |
| **Copilot CLI** | `copilot plugin marketplace add` then `copilot plugin install` |
| **Copilot cloud agent** | Declarative: `enabledPlugins` in `.github/copilot/settings.json` |
| **GitHub Copilot app** | Customize → Plugins → browse marketplaces |

---

## Exercise

1. Register `nl-its-cloud-ai-marketplace` in your VS Code
2. Install `diagram-design@nl-its-cloud-ai-marketplace`
3. Ask Copilot Chat to create a simple architecture diagram using the plugin agent
4. Add `enabledPlugins` to a test repo and open a PR

---

## Related workshops

- [Workshop 1 — Agentic stack & how it fits together](./workshop-01-agentic-stack.md)
- [Workshop 3 — Continue with skills](./workshop-03-skills.md)
- Workshop 4 — Brainstorm next steps ([marketplace §14](../nl-its-cloud-copilot-marketplace.md#14-workshop-series))

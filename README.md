# Agentforce-Slack

Salesforce **Agentforce** sample project focused on **Slack**: employee agents, Slack connections, and automation that posts to Slack (for example time audits and project notifications).

Use this repo as a companion to sessions about **Agentforce + Slack** (for example TrailblazerDX). Point a QR code at this URL so attendees land here:

**https://github.com/emoralesventix/Agentforce-Slack**

---

## What’s in this repo

- **Agent authoring bundles** under `force-app/main/default/aiAuthoringBundles/` (Agent Script `.agent` files).
- **Flows** that integrate with Slack and Agentforce (for example notifications and scheduled audits).
- **Apex** and **custom metadata** supporting time tracking, audits, and related automation.

---

## Agentforce + Slack (concept)

- Build and configure agents in **Salesforce** (Agentforce Builder / Studio), then expose them in **Slack** so users work with agents where they already collaborate.
- Official overviews:
  - [Getting started with Agentforce in Slack](https://docs.slack.dev/ai/getting-started-with-agentforce) (Slack Developer Docs)
  - [Set up and manage Agentforce in Slack](https://slack.com/help/articles/36218109305875-Set-up-and-manage-Agentforce-in-Slack) (Slack Help)
  - [Deploy an Employee Agent for Slack](https://help.salesforce.com/s/articleView?id=ai.agent_deploy_emp_slack.htm) (Salesforce Help)
- Learning paths:
  - Trailhead: [Connect Your Agentforce Org with Slack](https://trailhead.salesforce.com/content/learn/projects/connect-your-agentforce-org-with-slack)
  - Salesforce Admins: [Getting Started With Slack and Agentforce Integration](https://admin.salesforce.com/blog/2025/getting-started-with-slack-and-agentforce-integration)

---

## Install Agentforce DX (VS Code) — required for Agent Script

Agentforce DX lets you **edit, validate, preview, trace, and test** agents from VS Code. The **Agent Script Language Server** gives syntax highlighting, validation, and navigation for `.agent` files.

### Prerequisites

1. **[Visual Studio Code](https://code.visualstudio.com/)**
2. **[Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm)** (`sf`) on your PATH  
   - In a terminal: `sf version`  
   - Explore agent commands: `sf search` → type `agent`
3. **Salesforce Extension Pack** for VS Code (includes Agentforce DX, Agent Script support, Apex tooling, and more)  
   - [VS Code Marketplace — Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)  
   - Alternative registry: [Open VSX — Salesforce Extension Pack](https://open-vsx.org/extension/salesforce/salesforcedx-vscode)

The pack includes **Agentforce DX** explicitly; you can also install it directly:

- [Agentforce DX (VS Code Marketplace)](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode-agents)
- [Agent Script Language Server](https://marketplace.visualstudio.com/items?itemName=salesforce.agent-script-language-client) (also bundled with the pack)

### Quick install checklist

| Step | Action |
|------|--------|
| 1 | Install VS Code |
| 2 | Install Salesforce CLI |
| 3 | In VS Code Extensions, install **Salesforce Extension Pack** (or at minimum **Agentforce DX** + prerequisites above) |
| 4 | Open this folder in VS Code |
| 5 | Authorize an org: Command Palette → **SFDX: Authorize an Org** |

Detailed environment setup (orgs, permissions, scratch orgs, agent user):

- [Set Up Your Development Environment for Agentforce DX](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-set-up-env.html)
- [Agentforce DX (developer guide hub)](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx.html)

---

## Configure and work with Agent Script

The **Agent Script** (`.agent` file) is the agent blueprint: topics, reasoning instructions, actions, variables, and Slack connections.

### Where the files live

Authoring bundles live under your package directory, for example:

`force-app/main/default/aiAuthoringBundles/<Agent_API_Name>/<Agent_API_Name>.agent`

### Everyday workflow

1. Open the `.agent` file in VS Code.
2. Edit topics, `system` / `config` / `variables`, and `connection slack` blocks as needed.
3. **Validate**: right-click the script → **AFDX: Validate This Agent**, or use the CLI from the project root, for example:  
   `sf agent validate authoring-bundle`  
   (Use `sf agent validate authoring-bundle --help` for options such as `--api-name`.)
4. **Preview** in VS Code to chat with the agent (including simulated mode when actions are not fully deployed). See [Preview and Debug an Agent](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-nga-preview.html).
5. **Publish** to your org when ready: [Publish an Authoring Bundle to Your Org](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-nga-publish.html).

### Essential documentation

| Topic | Link |
|--------|------|
| Code your agent (Agent Script file) | [Code Your Agent Using Its Agent Script File](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-nga-script.html) |
| Agent Script language reference | [Agent Script](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-script.html) |
| Example recipes | [Agent Script recipes (GitHub)](https://github.com/trailheadapps/agent-script-recipes) · [Sample apps documentation](https://developer.salesforce.com/sample-apps/agent-script-recipes) |
| Salesforce CLI `agent` commands | [CLI reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_top.htm) (search for `agent`) |
| Extension issues / releases | [vscode-agents (GitHub)](https://github.com/forcedotcom/vscode-agents/releases) |

Tips from the docs: set `default_user_agent` in the `config` block to the username of the Salesforce user that runs the agent; use **simulated preview** while Apex/flows are still in progress. See the [Agent Script coding guide](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-nga-script.html) for details.

---

## Salesforce DX project

- Project config: `sfdx-project.json`
- Default package directory: `force-app/`
- Deploy/retrieve using Salesforce CLI and/or VS Code commands, per your team’s practice.

Generic DX references:

- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce Extensions for VS Code](https://developer.salesforce.com/tools/vscode/)

---

## License and disclaimer

This repository is intended for **demonstration and learning**. Review security, data residency, and licensing for Agentforce and Slack in your own org before production use. Salesforce, Agentforce, and Slack are trademarks of their respective owners.

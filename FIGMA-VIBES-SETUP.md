# Figma → Agentforce Vibes Setup Guide (Session 1693)

**Verdict: YES, it's possible — and it's officially supported.** Salesforce publishes a
step-by-step guide for exactly our session's workflow: *"Turn a Figma UI design into component
code with Agentforce Vibes"* using the Figma MCP + Salesforce DX MCP.

> Primary source: [Vibe Coding and SLDS](https://www.lightningdesignsystem.com/2e1ef8501/p/75a154-vibe-coding-and-slds)
> (Lightning Design System 2 site → AI and SLDS 2 → Vibe Coding and SLDS)

---

## 1. Do I need the Figma desktop app? (Short answer: **NO**)

There are **three ways** to give the AI access to Figma design data — only one needs the desktop app:

| Option | Desktop app? | Figma plan needed | Auth | Notes |
|---|---|---|---|---|
| **A. Desktop (local) Figma MCP server** — `http://127.0.0.1:3845/mcp` | ✅ Yes (v2.103.7+, Dev Mode) | ❌ **Paid Dev/Full seat** required | none (local) | Richest experience: works off your *current selection*, Code Connect mapping. This is what the SLDS "Vibe Coding" guide shows. |
| **B. Remote Figma MCP server** — `https://mcp.figma.com/mcp` | ❌ No | Free works, **but** Starter/View seats get only **~6 tool calls per MONTH** (10/min). Pro + Dev/Full seat = 200/day. | OAuth (browser login) | Free-plan rate limit makes it useless for real prep — one Vibes run can burn several calls. |
| **C. Framelink MCP server** (community, **documented by Salesforce** in the LWC dev guide) | ❌ No | ✅ **Free account OK** (uses the Figma REST API; API rate limits apply) | Personal access token (read on *File content* + *Dev resources*) | The path in [Generate LWC from Figma (Beta)](https://developer.salesforce.com/docs/platform/lwc/guide/mcp-design.html). Reads the design from a plain file link. |

**Recommendation for us:**
- **Now (free account): use Option C — Framelink.** It's the officially documented Salesforce path for Figma→LWC with DX MCP, needs no desktop app and no paid seat.
- **For the stage demo: budget 1 month of Figma Professional with a Dev seat** (~cheap, expense it) so we can show Option A — the Dev Mode "current selection" flow from the SLDS guide is visually stronger on stage, and gives us 200 calls/day headroom for rehearsals.

### Setting up Option C (free account, no desktop app)

1. In Figma web: profile icon → **Settings** → **Security** tab → **Personal access tokens** → *Generate new token* with **read** scopes on **File content** and **Dev resources**.
2. Add the Framelink server to your MCP config (VS Code `settings.json` / client MCP config) — it runs via `npx` (package `figma-developer-mcp`); see the [Framelink quickstart](https://www.framelink.ai/docs/quickstart) for the exact snippet per client, e.g.:
   ```json
   {
     "mcpServers": {
       "Framelink Figma MCP": {
         "command": "npx",
         "args": ["-y", "figma-developer-mcp", "--figma-api-key=YOUR_TOKEN", "--stdio"]
       }
     }
   }
   ```
3. Enable the DX MCP **`lwc-experts`** toolset. Key tools from the [official doc](https://developer.salesforce.com/docs/platform/lwc/guide/mcp-design.html):
   - `guide_figma_to_lwc_conversion` — orchestrates the Figma→LWC conversion (beta)
   - `figma_data_tool` — reads design data via Framelink
   - `create_lwc_component_from_prd` — scaffolds the component
4. Prompt example from the doc: *"Convert this Figma design to LWC. Link to Figma file: `https://www.figma.com/design/<your-design-url>`"* — it extracts design tokens (spacing, color, radius, typography), maps them to SLDS variables, and generates the component plan + files.
5. Copy the design link with **right-click → Copy link to selection** (free plan) — the `node-id` in the link targets the exact frame.

---

## 2. What Figma gives us (official SLDS kits)

From [Figma Kits](https://www.lightningdesignsystem.com/2e1ef8501/p/2963ba-figma-kits) on the SLDS 2 site:

### SLDS 2 (use these — new, AI-ready)

| Kit | Type | Link |
|---|---|---|
| **SLDS 2 Style Guide** | Foundations | https://www.figma.com/community/file/1415017035637927819 |
| **SLDS 2 Web Components UI Library** | Components | https://www.figma.com/community/file/1399892502513202095 |
| **SLDS 2 Pattern: Agentic Experience** ⭐ | Pattern | https://www.figma.com/community/file/1478970084463860424 |
| **SLDS 2 Pattern: Builder** | Pattern | https://www.figma.com/community/file/1415890669347272207 |

⭐ **The Agentic Experience kit is our session's secret weapon** — it's the official Figma library
for designing generative-AI interfaces on the Lightning Platform. Our session is literally titled
*"Vibe Coding Your **Agentic UI**"*: designing the demo component from this kit ties the whole
story together (design an agent-panel UI → vibe-code it into an LWC).

### SLDS 1 (legacy — mention only, don't build on these)

| Kit | Link |
|---|---|
| SLDS 1 Typography | https://www.figma.com/community/file/854596438801119898 |
| SLDS 1 Color | https://www.figma.com/community/file/854594537376275097 |
| SLDS 1 Icons | https://www.figma.com/community/file/854597149359643291 |
| Components for Web (SLDS 1) | https://www.figma.com/community/file/854593583696357016 |
| Pattern: Builder (Beta) | https://www.figma.com/community/file/881232048471166510 |
| Pattern: Confetti (Beta) | https://www.figma.com/community/file/1276948198508782378 |
| Pattern: Console UI (Beta) | https://www.figma.com/community/file/1276949149344012079 |
| Pattern: Charts | https://www.figma.com/community/file/854599280117867164 |

**How kits work:** open the community file in Figma → *Open in Figma / Duplicate* → it becomes a
library you can enable in your own file, then drag-and-drop components into your design.
Community files are **free to duplicate** — you can build the demo design on a free account.

---

## 3. The official architecture (this is our concept slide)

From the Vibe Coding and SLDS "Workflow" tab — Salesforce's own construction analogy:

| Role in the analogy | Actual tool | Function |
|---|---|---|
| Construction manager | **Agentforce Vibes** (VS Code extension or Vibes IDE in a sandbox) | LLM agent: planning, tool-calling, code generation |
| Blueprint | **Figma design link** (Dev Mode link to a frame/component) | Visual + structural design spec |
| Building code manual | **Figma MCP** + **Salesforce DX MCP** | Governed rules: design data extraction + LWC/SLDS 2 compliance |

The 4-step flow (great demo narration):
1. **Prompt** — you give Vibes a natural-language task + the Figma link; it recognizes the intent and decides it needs the Figma MCP.
2. **Figma MCP** — using the `node-id` in your link, it pulls structure (auto-layout, hierarchy → flexbox/grid), styling (SLDS 2 design tokens, hex, typography, spacing), and Code Connect component mappings (e.g., Figma button → `lightning-button`).
3. **Synthesis** — Vibes combines your prompt + org context (via DX MCP: metadata, schema, project files) + design context, plans which SLDS 2 utility classes and base components to use, and writes HTML/JS/CSS/XML.
4. **Delivery** — files land in your DX project; you review, accept, and deploy.

---

## 4. Step-by-step setup (paid / desktop path — the SLDS guide's version)

### A. Figma side

1. Install the **Figma Desktop app** (v2.103.7+ required for the MCP server).
2. Create a Figma file and enable the SLDS 2 libraries (duplicate the kits above; build the demo design from **Agentic Experience** + **Web Components** kits so tokens map to real styling hooks).
3. Enter **Dev Mode** (`Shift + D`).
4. In the Dev Mode inspect panel → MCP server section → **Enable desktop MCP server** (or "Set up Figma MCP"). Server status should read **Local server** → runs at `http://127.0.0.1:3845/mcp`.
5. Select the frame/component you want to build and copy the Dev Mode link: `Ctrl + L` (Windows) / `Cmd + L` (Mac). This link (with its `node-id`) is what you paste into the Vibes prompt.

### B. Salesforce / VS Code side (two officially supported paths)

**Path 1 — VS Code (recommended for a stage demo):**
1. Install VS Code + **Salesforce Extension Pack** (includes the **Agentforce Vibes extension** and bundles the **Salesforce DX MCP** + SLDS Linter).
2. Have a **Salesforce DX project** and a **sandbox/org** authorized (Dev Hub if using scratch orgs).
3. Register the Figma MCP server in VS Code `settings.json` (Ctrl+Shift+P → *Open User Settings (JSON)*). Figma's official config:
   ```json
   {
     "servers": {
       "figma-desktop": { "type": "http", "url": "http://127.0.0.1:3845/mcp" }
     }
   }
   ```
   (Remote variant: `"url": "https://mcp.figma.com/mcp"` + OAuth. Free-account variant: Framelink — see section 1.)
4. Open the Vibes panel (Codey avatar), optionally enable **Auto-Approve** for metadata deploys, and auth into the sandbox.

**Path 2 — Salesforce sandbox (zero local install):** as of **Spring '26 all sandboxes include the Agentforce Vibes IDE** (formerly Code Builder) under Setup → Agentforce Vibes, with DX MCP, Salesforce CLI, and SLDS Linter pre-installed. Nice to *mention* on stage as the no-setup path; the Figma MCP still needs configuring.

### C. Run the flow (the demo moment)

Official example prompt (adapt to our component):

> *"Grab the currently selected [component] from Figma by using the Figma MCP server. Build it as a Lightning Web Component (LWC), and use Lightning base components if possible. Then deploy it to my org. Use the Salesforce DX MCP server as necessary. [Figma Dev Mode link]"*

1. Paste prompt + Figma link into Vibes → it plans, calls the Figma MCP, generates HTML/JS/CSS/XML.
2. Click **Accept / Save / Run Command** as it works (takes a few minutes — have narration ready).
3. Success message looks like: *"Implemented an SLDS 2-compliant [component] aligned with the provided Figma design link... leveraging SLDS 2 global styling hooks (--slds-g)."*
4. In Lightning App Builder (keep it pre-opened on an Edit Page), **drag the new component onto the page** → side-by-side with the Figma original. 🎤⬇️

### D. Governance beat (learning objective #3)

- The generated CSS uses **SLDS 2 global styling hooks (`--slds-g-*`)** — DX MCP enforces SLDS Linter rules during generation (governance *built into* the pipeline, not bolted on).
- Then run **Code Analyzer** (`sf code-analyzer run`) on the generated component live.
- Slide mention: Trust Layer + the DX MCP's "predictable, secure, structured context" framing from the official docs. The DX MCP also has an **`experts-validation`** toolset (production-readiness validation) worth showing or citing.

---

## 5. Open items / risks

- [ ] **Free account now**: set up the Framelink path (section 1.C) and validate the flow end-to-end this month.
- [ ] **Figma seat for the demo**: expense ~1–2 months of Figma Professional + Dev seat (Sept–Oct) for the desktop MCP experience and rehearsal headroom (200 calls/day vs 6/month on free).
- [ ] **Timing**: generation "takes a few minutes" — rehearse narration to cover it; backup video is mandatory.
- [ ] **Feature drift**: Vibes + Figma MCP + the Figma→LWC beta tools are evolving fast; re-verify every step in September on the exact demo laptop.
- [ ] Try the **SLDS 2 AI Starter Kit** (local dev template for prototyping Salesforce experiences) — possible attendee takeaway link.

---

## 6. Official documentation index

### Salesforce — Lightning Design System 2 (lightningdesignsystem.com)

| Doc | URL |
|---|---|
| Lightning Design System 2 (overview) | https://www.lightningdesignsystem.com/2e1ef8501/p/85bd85-lightning-design-system-2 |
| Figma Kits (all kit links) | https://www.lightningdesignsystem.com/2e1ef8501/p/2963ba-figma-kits |
| **Vibe Coding and SLDS** (our session's blueprint: Overview / Workflow / Prerequisites / Sandbox / VS Code) | https://www.lightningdesignsystem.com/2e1ef8501/p/75a154-vibe-coding-and-slds |
| AI Tools (SLDS 2 as AI-consumable; "up to 30% more accurate code") | https://www.lightningdesignsystem.com/2e1ef8501/p/2337c1-ai-tools |
| AI and SLDS 2 (section hub) | https://www.lightningdesignsystem.com/2e1ef8501/p/52a7c7-ai-and-slds-2 |
| Designers hub | https://www.lightningdesignsystem.com/2e1ef8501/p/874349-designers |
| Styling Hooks | https://www.lightningdesignsystem.com/2e1ef8501/p/319e5f-styling-hooks |
| Global Styling Hooks | https://www.lightningdesignsystem.com/2e1ef8501/p/591960-global-styling-hooks |
| SLDS 2 AI Starter Kit | https://www.lightningdesignsystem.com/2e1ef8501/p/057d3b |
| Agentic Patterns | https://www.lightningdesignsystem.com/2e1ef8501/p/03c548-agentic-patterns |

### Salesforce — Developer docs (developer.salesforce.com)

| Doc | URL |
|---|---|
| **Generate LWCs from Figma Designs (Beta)** — Framelink + `guide_figma_to_lwc_conversion` | https://developer.salesforce.com/docs/platform/lwc/guide/mcp-design.html |
| DX MCP Tools for LWC (Beta) — intro & toolsets (`lwc-experts`, `aura-experts`, `experts-validation`) | https://developer.salesforce.com/docs/platform/lwc/guide/mcp-intro.html |
| Agentforce Vibes (product page) | https://www.salesforce.com/agentforce/developers/vibe-coding/ |
| Agentforce Vibes Extension (VS Code Marketplace, in Salesforce Extension Pack) | https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-einstein-gpt |
| Salesforce Extension Pack (VS Code Marketplace) | https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode |
| Salesforce Extensions for VS Code (guide) | https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide |
| Agentforce Vibes IDE / Code Builder (overview) | https://developer.salesforce.com/docs/platform/code-builder/guide/codebuilder-overview.html |
| Einstein for Developers docs (Vibes docs home) | https://developer.salesforce.com/docs/platform/einstein-for-devs/overview |
| LWC Developer Guide | https://developer.salesforce.com/docs/platform/lwc/guide |
| Trailhead: Agentforce Vibes / Einstein for Developers | https://trailhead.salesforce.com/content/learn/modules/einstein-for-developers |

### Figma — MCP server & tokens (figma.com)

| Doc | URL |
|---|---|
| Guide to the Figma MCP server (Help Center) | https://help.figma.com/hc/en-us/articles/32132100833559-Guide-to-the-Figma-MCP-server |
| Figma MCP server (developer docs intro) | https://developers.figma.com/docs/figma-mcp-server/ |
| Remote server installation (`https://mcp.figma.com/mcp`, OAuth) | https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/ |
| Desktop server installation (`http://127.0.0.1:3845/mcp`) | https://developers.figma.com/docs/figma-mcp-server/local-server-installation/ |
| **Rate limits & access by plan/seat** (free = ~6 calls/month!) | https://developers.figma.com/docs/figma-mcp-server/rate-limits-access/ |
| Manage personal access tokens | https://help.figma.com/hc/en-us/articles/8085703771159-Manage-personal-access-tokens |

### Community server documented by Salesforce

| Doc | URL |
|---|---|
| Framelink quickstart (Figma MCP for any client, free-account friendly) | https://www.framelink.ai/docs/quickstart |

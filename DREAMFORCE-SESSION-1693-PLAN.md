# Dreamforce Session 1693 — Preparation Plan

**From Figma to Flow: Vibe Coding Your Agentic UI**

> Learn how to transform Figma designs into production-ready Salesforce components using
> Agentforce Vibes and Model Context Protocol (MCP) to bridge the gap between design and development.

## Session Facts

| Item | Value |
|---|---|
| Session ID | 1693 |
| Format | Theater, In-Person, 20 minutes |
| Audience | Designer (primary), Architect (secondary) |
| Track / Theme | Agentforce · Technology · Agentic AI |
| Speakers | Esteban Morales (emorales@ventixsolutions.com), Josue Mendoza (jmendoza@ventixsolutions.com) |
| Session owner (Salesforce) | Hsiao-Ching Chou (h.chou@salesforce.com) — will send template + deadlines |
| Hands-on | No |

## Promised Learning Objectives (the demo arc)

1. **Connect** Figma to Agentforce Vibes using MCP to provide design context to your AI coding partner.
2. **Generate** production-ready Lightning Web Components (LWC) from natural-language prompts grounded in Figma designs.
3. **Govern** AI-generated code using the Salesforce Trust Layer and Code Analyzer.

## Deliverables Checklist

### 1. The Demo (core — ~10–12 of the 20 minutes)

- [x] **Figma MCP connected to Agentforce Vibes** — DONE (July 4): Framelink MCP server connected in the Vibes Toolkit (free Figma account, personal access token). See FIGMA-VIBES-SETUP.md.
- [x] **End-to-end proof** — DONE (July 4): SLDS 2 kit "Accounts" card → `get_figma_data` → generated `accountsCard` LWC in 1m44s with lightning base components + `--slds-g-*` styling hooks, zero hardcoded colors.
- [ ] **Wire to real org data** — Apex controller + `@wire` (Contacts with Title), test class, deploy, drag onto page in App Builder.
- [x] **Demo component CHOSEN** (July 4): the **Agentforce chat panel** from the SLDS 2 Agentic
  Experience kit (Patterns → Panel) — header, agent/user conversation, embedded record card
  (Vandelay Industries example), feedback buttons, "Describe your task…" input. Select ONLY the
  panel frame, not the surrounding Builder screen. Working name: `agentPanel`.
  - Why: it *is* the "Agentic UI" of the title; the embedded record card reuses the accountsCard
    data-wiring story (agent surfaces real org data in conversation).
  - [ ] Test-convert it with Vibes (same flow as accountsCard) to confirm it generates cleanly.
- [ ] **Code Analyzer run** on the generated component (governance beat, learning objective #3) + slide-level Trust Layer mention.
- [ ] **Pre-built "golden" version** of the component (fallback if live generation misbehaves).
- [ ] **Backup screen recording** of the full demo (conference Wi-Fi insurance — never demo without it).
- [ ] **Figma paid Dev seat** (Sept–Oct) for the desktop MCP "current selection" flow + rehearsal rate-limit headroom; free-plan Framelink path proven as fallback.

### 2. The Content

- [ ] Slide deck on the official Dreamforce template (minimal — theater sessions live on the demo).
- [ ] Talk track split between Esteban and Josue (e.g., one drives the demo, the other narrates concepts; swap at governance).
- [ ] **Companion GitHub repo + QR code** (same playbook as the TDX Agentforce-Slack repo): Figma file link, exact prompts, generated code, setup instructions.

### 2.4 Making the generated UI REAL (the "is it just a shell?" answer)

A Figma-generated component is view-layer only — data and behavior are wired afterward. Three
levels, each with a place in the session:

| Level | What | Where it's shown |
|---|---|---|
| 1. Static shell | Generated panel renders scripted `@api` data | (skip — invites "does it do anything?") |
| 2. Wired UI | Apex + `@wire` feeds real org data (accountsCard pattern) | **Live demo core** |
| 3a. **ACC integration** | Generated UI calls `lightning/accApi`: `open(botId)` + `execute(utterance, botId)` → the REAL Agentforce panel opens and a REAL agent answers. ~5 lines of JS, no Connected App/Named Credential. | **Live demo finale** |
| 3b. Agent API custom surface | Custom chat UI rendering agent responses via the Agent API (Apex + Named Credential + Connected App) | Companion repo + backup video only |

ACC facts (verified, [official doc](https://developer.salesforce.com/docs/platform/accsdk/guide/acc-api.html)):
module `lightning/accApi`; methods `open(botId?)`, `execute(utterance, botId)` (queued, does NOT
return the agent's text response — it drives the standard panel), `close()`. Requires API 59+,
Lightning Experience desktop, Agentforce enabled. Bot ID comes from the Agent Builder URL.
We already have agents in the org (`Agentforce_Management_Assistant`, `Vantegrate_Agent`) to
target.

### 2.5 What goes in the LIVE DEMO vs the DECK

**Live demo (screen time, ~10–12 min):**
1. Figma: show the Agentic Experience kit, select the Agentforce panel frame, copy link (30s).
2. Vibes: paste the prepared prompt → approve `get_figma_data` → narrate the 4-step MCP workflow
   while it generates (~2 min of generation = narration window).
3. Show the generated files: point at `lightning-*` base components and `--slds-g-*` hooks — "zero
   hardcoded colors" (1 min).
4. Deploy + Lightning App Builder: drag `agentPanel` onto a page, side-by-side with the Figma
   original (2 min).
5. Governance: `sf code-analyzer` run on the generated component (2 min).

**Deck only (no live demo needed):**
- The construction analogy / architecture slide (Vibes = manager, Figma link = blueprint,
  MCPs = building code) — from the official SLDS "Vibe Coding and SLDS" page.
- Figma kits overview slide: the 4 SLDS 2 kits + what a kit gives you (tokens → styling hooks).
- "Up to 30% more accurate code" stat (official AI Tools page).
- Trust Layer slide (learning objective #3, paired with the live Code Analyzer moment).
- Free vs paid Figma paths (Framelink vs Dev Mode MCP) — attendees will ask; one table slide.
- **Astro sticker sheet from the Agentic Experience kit = approved deck art** (follow the kit's
  Branding Guidelines: use provided avatar, don't alter).
- QR code → companion repo.

### 3. Proposed 20-Minute Structure

| Time | Beat |
|---|---|
| 0–2 min | Hook: the design-to-dev gap ("the designer's Figma is pixel-perfect; what ships is... not") |
| 2–5 min | Concepts: Agentforce Vibes, MCP, one architecture slide (Figma → MCP → Vibes → LWC → org) |
| 5–15 min | **Live demo**: open Figma design → Vibes pulls design context via MCP → prompt → generated LWC → deploy → render side-by-side with the Figma original |
| 15–18 min | Governance: Code Analyzer on the generated code; Trust Layer framing ("AI-generated ≠ ungoverned") |
| 18–20 min | Recap 3 takeaways, QR code, CTA |

## Work Plan (order of attack)

1. **Research current tooling** — verify Figma MCP + Agentforce Vibes setup as of July 2026; re-verify in September (both evolve fast). ← *in progress*
2. **Scaffold the demo project** — fresh repo (current one is Slack-branded) with target LWC, app page, README.
3. **Write the demo runbook** — exact prompts, exact clicks, timings, fallback plan.
4. **Draft talk track + slide outline** for both speakers to react to.

## Timeline (Dreamforce ≈ mid-October 2026)

- **July**: tooling research, Figma design built, first end-to-end demo working.
- **August**: demo runbook stable, companion repo drafted, slide outline.
- **September**: slides on official template, dry runs, re-verify tooling versions, record backup video.
- **October**: final dry run on conference-like conditions, freeze everything ~1 week out.

## Setup — Figma & SLDS Kits

Research done — the workflow is **officially supported and documented** by Salesforce
("Vibe Coding and SLDS" on the SLDS 2 site). Full step-by-step setup, kit links, the official
demo prompt, and open risks live in the companion guide:

➡️ **[FIGMA-VIBES-SETUP.md](FIGMA-VIBES-SETUP.md)**

Highlights:
- Use the **SLDS 2 Figma kits** (Style Guide, Web Components, and especially the
  **Agentic Experience pattern kit** — perfect match for the "Agentic UI" session title).
- Figma Desktop (v2.103.7+) in **Dev Mode** with the local **Figma MCP server**
  (`http://127.0.0.1:3845/mcp`) — requires a paid Dev/Full seat (budget item); remote server
  (`https://mcp.figma.com/mcp`) works on all plans as fallback.
- VS Code + **Salesforce Extension Pack** (Agentforce Vibes extension bundles the Salesforce DX
  MCP + SLDS Linter); as of Spring '26 sandboxes also ship the Agentforce Vibes IDE.
- Official example prompt + Lightning App Builder drag-and-drop finale documented in the guide.

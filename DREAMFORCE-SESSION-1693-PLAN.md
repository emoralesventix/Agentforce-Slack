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

- [ ] **Figma design file** of a realistic component (candidate: customer account card or performance dashboard widget — existing `accountStatementDemo` / `stationPerformanceDashboardDemo` LWCs can inspire it). Build it with the official **SLDS 2 Figma kits** so tokens map cleanly to Lightning styling hooks.
- [ ] **Figma MCP server** connected to **Agentforce Vibes** in VS Code — the "wow" moment: the AI reads real design tokens/layout from Figma.
- [ ] **Demo org** with a target app page ready, so the generated LWC drops in and renders live.
- [ ] **Code Analyzer run** on the generated component (governance beat) + slide-level Trust Layer mention.
- [ ] **Pre-built "golden" version** of the component (fallback if live generation misbehaves).
- [ ] **Backup screen recording** of the full demo (conference Wi-Fi insurance — never demo without it).

### 2. The Content

- [ ] Slide deck on the official Dreamforce template (minimal — theater sessions live on the demo).
- [ ] Talk track split between Esteban and Josue (e.g., one drives the demo, the other narrates concepts; swap at governance).
- [ ] **Companion GitHub repo + QR code** (same playbook as the TDX Agentforce-Slack repo): Figma file link, exact prompts, generated code, setup instructions.

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

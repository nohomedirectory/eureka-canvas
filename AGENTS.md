# AGENTS.md — Eureka Canvas

**Project:** Eureka Canvas — spatial thinking workspace with Gemini Live API
**Hackathon:** Gemini Live Agent Challenge (Devpost)
**Category:** Live Agents
**Deadline:** March 16, 2026, 5:00 PM PDT (submit by 4:00 PM PDT — 1-hour buffer)
**Prize target:** Grand Prize ($25,000 + Google Cloud Next stage demo)

---

## What This Is

A voice-first spatial canvas where Gemini silently crystallizes the user's spoken thoughts into visual cards, clusters them via force-directed physics, creates synthesis insights, runs background research, and schedules Calendar events. The agent doesn't respond to you — it thinks alongside you. The canvas IS the interface, not a chat thread.

**The spec (`spec.md`) is the single source of truth for all implementation details.** Read it before working on any bead. The README (`README.md`) is the judge-facing document — do not modify it without checking spec consistency.

---

## Stack

| Layer | Tech |
|-------|------|
| Frontend | Next.js (App Router), React, TypeScript |
| Canvas | Absolutely-positioned divs, CSS transforms, SVG edges, d3-force |
| Voice | AudioWorklet (48kHz→16kHz capture), Web Audio API (24kHz→system rate playback) |
| Backend | Node.js on Google Cloud Run, WebSocket proxy |
| Model | `gemini-2.5-flash-native-audio-preview-12-2025` via Gemini Live API |
| SDK | `@google/genai` (Google GenAI SDK) — **required by hackathon rules** |
| Persistence | Google Cloud Firestore |
| Research | Separate `generateContent` call with Google Search grounding |
| External action | Google Calendar API (pre-authorized OAuth) |
| Layout physics | d3-force (~50 lines) |

---

## HARD RULES — EVERY AGENT MUST FOLLOW THESE

### Rule 1: Effective P0 — What MUST Ship for the Demo

The spec has P0/P1/P2 tiers, but the demo script (spec §13.2) requires features from P1. **For this build, the following are ALL treated as P0:**

From spec P0 (§4.3):
- Canvas with artifact rendering and drag support
- Voice session plumbing (AudioWorklet capture, playback, transcript)
- Live API function-call loop
- `create_card`, `move_artifact`, `create_calendar_event` tools
- Agent persona and silent crystallization behavior
- Card creation animations (ghost → solid, 300ms)
- Firestore persistence
- Cloud Run deployment (`--timeout=3600 --min-instances=1`)
- User drag detection → context injection with edge creation
- Synthesis cards (status: "synthesis", dashed border, triggered at 5+ cards)

**Promoted from P1 to effective P0** (required by demo shots):
- **Force-directed semantic layout** (d3-force) — demo Shot 2 and Shot 5
- **Canvas replay** (state snapshots + timeline scrubber) — demo Shot 5
- **Topology analysis injection** — demo Shot 2 (agent's insight comes from this)
- **Research cascading** (results as individual cards entering force simulation) — demo Shot 4
- **`start_research_job` with Google Search grounding** — demo Shot 4
- **Blog post + deploy script + GDG signup** — +1.0 bonus points (10% of max score)
- **Demo video recording + editing** — this IS the submission

**Everything else is P2. Do NOT build P2 features.** Specifically, do NOT build:
- `group_artifacts` tool
- Multi-view transformations
- `delete_artifact` and undo
- Task DAG rendering
- Thinking budget indicator
- Dynamic system instruction mutation (P1 #7 — nice but not in demo script)
- On-demand canvas screenshots (P1 #4 — spatial refs work from structured state)
- Light/dark theme toggle (P1 #8)

### Rule 2: Audio Pipeline is the Critical Path

**Nothing works without the audio pipeline.** No cards, no voice, no tools, no demo. The dependency chain is:

```
AudioWorklet capture → WebSocket to backend → Backend proxy to Gemini Live API → Tool calls work → Everything else
```

**If you are working on a bead that requires a live Gemini session and the audio pipeline is not yet green, STOP.** Work on canvas UI with mock data, backend infrastructure, or non-code deliverables instead.

**Canvas UI beads CAN proceed with mock data.** Create mock tool call responses and render cards, animations, force layout, replay — all without a live session. Integration beads will wire them together later.

### Rule 3: Default to BLOCKING Tools

The spec documents two approaches for silent card creation:
- **NON_BLOCKING + FunctionResponseScheduling.SILENT** — elegant but unreliable (known API issue: model narrates during tool execution)
- **BLOCKING (default)** — simple, guaranteed silent during tool execution

**Default to BLOCKING for all canvas tools.** The model literally cannot speak while a blocking tool executes. After the response, the system prompt's "NEVER narrate tool calls" instruction handles silence.

This means:
- Do NOT set `behavior: Behavior.NON_BLOCKING` on canvas tool declarations
- Do NOT use `FunctionResponseScheduling` in tool responses
- Do NOT implement "during speech" vs "after pause" scheduling logic
- The system prompt + blocking behavior provides silence

**If time permits and all P0 beads are done,** an upgrade bead can switch to NON_BLOCKING + SILENT. But do not build for it initially.

**IMPORTANT:** The README and spec reference NON_BLOCKING + SILENT extensively. That's correct for the judge-facing documentation (it shows SDK knowledge). The implementation takes the reliable BLOCKING path. These are not contradictory — the README describes the architecture, the code takes the pragmatic path.

### Rule 4: Project Scaffold Bead Must Complete First

Before any implementation bead can start, the project must have:
- `package.json` with all dependencies (`next`, `react`, `@google/genai`, `d3-force`, `firebase-admin`, `googleapis`, `ws`, `uuid`)
- `tsconfig.json` with strict TypeScript
- `next.config.js` (or `.mjs`) with WebSocket support config
- `.env.example` with all required env vars
- Directory structure matching README §Repository structure
- `.gitignore`
- `spec.md` and `README.md` copied into repo root

**No other bead should be claimed until scaffold is green.**

### Rule 5: Calendar OAuth is a Human Checkpoint

The Google Calendar integration requires OAuth credentials that no agent can create. The code should:
- Accept `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `GOOGLE_REDIRECT_URI` from environment
- Implement the OAuth flow + token refresh in code
- Assume a pre-authorized refresh token will be available at runtime

There is a human checkpoint bead: "Create OAuth credentials in Google Cloud Console, authorize test account, store refresh token." This bead is assigned to the human and blocks the Calendar integration test bead, but NOT the Calendar code bead.

### Rule 6: Verify Model Name Early

`gemini-2.5-flash-native-audio-preview-12-2025` has a December 2025 date suffix. The very first bead that connects to the Gemini API must verify this model name resolves. If it doesn't, check [Google AI Studio](https://aistudio.google.com/) or the SDK docs for the current native audio preview model. Update `.env` and `README.md` if the name has changed.

---

## Architecture Decisions — FINAL, DO NOT REVISIT

These are from spec §16. Do not spend cycles debating them:

| Decision | Choice |
|----------|--------|
| Architecture | Server proxy (NOT client-direct) |
| API auth | Gemini Developer API (API key, not Vertex AI) |
| API version | `v1alpha` (required for Proactive Audio config) |
| Audio capture | AudioWorklet with downsample, NOT MediaRecorder |
| Audio playback | Web Audio API at system default rate, resample from 24kHz |
| Canvas | Absolutely-positioned divs + CSS transforms, NOT canvas element |
| Layout | d3-force with direct DOM manipulation during simulation, sync to React state after settle |
| Coordinates | (0,0) at viewport center, ~1200×800 visible area |
| Ghost cards | 300ms solidification, artifact already persisted when ghost renders |
| Research | Separate `generateContent` call, NOT Live API inline search |
| Calendar auth | Pre-authorized test account |
| Proactive Audio | Enabled in config, BUT silent crystallization must work without it |
| Thinking budget | 512 tokens |
| Silence duration | 700ms (500ms for demo recording) |

---

## File Ownership Patterns

When reserving files, use these patterns:

| Track | Files |
|-------|-------|
| Canvas UI | `components/Canvas.tsx`, `components/ArtifactCard.tsx`, `components/DagEdge.tsx`, `components/JobNode.tsx`, `components/CanvasReplay.tsx`, `components/TranscriptPanel.tsx`, `components/Controls.tsx` |
| Audio pipeline | `lib/live/**`, `lib/audio/**` |
| Tool executor | `lib/tools/**` |
| Force layout | `lib/layout/**` |
| Replay | `lib/replay/**` |
| Firestore | `lib/firestore/**` |
| Calendar + Research | `lib/google/**` |
| Backend server | `app/api/**`, server WebSocket files |
| Non-code | `scripts/deploy.sh`, `docs/**`, `public/architecture.png` |

**Do not modify files outside your reservation without coordinating via agent-mail.**

---

## Bead Completion Criteria

A bead is DONE when:
1. The code compiles without TypeScript errors
2. The feature works as described in the spec section referenced by the bead
3. If it's a UI bead: it renders correctly with mock data OR live data (whichever the bead specifies)
4. If it's a backend bead: it has basic error handling (try/catch, meaningful error messages)
5. No console errors in the browser
6. The bead's acceptance criteria (written in the bead description) are met
7. You've run the app and visually verified the feature works

A bead is NOT done if:
- It only exists as a plan or TODO comment
- It compiles but doesn't actually function
- It breaks other existing features (run the app and check)

---

## Coordination Pattern

1. Check `bv --robot-triage` for the next ready bead (no unmet dependencies)
2. Claim the bead: `bv claim <bead-id>`
3. Reserve your files via agent-mail
4. Implement
5. Test (run the app, verify visually)
6. Mark complete: `bv done <bead-id>`
7. Send a brief agent-mail update if your change affects other tracks

---

## Demo Recording Context

The demo is 70%+ of the score (Innovation 40% is judged from the demo, Demo 30% is the demo itself). Every feature you build must be VISIBLE in a 3:30 video. Features that work but can't be shown in the demo have near-zero value.

The demo script (spec §13.2) has 7 shots. Each shot exercises specific features. When implementing a feature, mentally verify: "Which demo shot does this appear in? If none, it's not P0."

---

## Time Context

It is submission day. Every minute matters. If you encounter a technical problem that will take more than 30 minutes to debug, flag it in agent-mail as URGENT and move to another bead. Someone else may have context that solves it faster. If a P0 feature is fundamentally blocked (e.g., a Gemini API bug), switch to the P0 fallback noted in spec §13.1.

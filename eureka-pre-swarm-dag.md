# Eureka Canvas: Pre-Swarm DAG & Bead Manifest

**Created:** March 16, 2026 — Submission Day
**Purpose:** Every step from RIGHT NOW to agents executing beads, plus the complete bead manifest.

---

## PART 1: PRE-SWARM DAG (Human Steps)

These steps must complete BEFORE agents can start executing beads.

```
STEP 1: Save corrected docs (YOU, 2 min)
  ├── Save fixed strategy doc
  ├── Save AGENTS.md
  └── No dependencies

STEP 2: Create project directory (YOU, 5 min)
  ├── mkdir eureka-canvas && cd eureka-canvas && git init
  ├── Copy spec.md, README.md, AGENTS.md into repo root
  ├── Depends on: STEP 1
  └── Output: empty git repo with docs

STEP 3: Create beads from manifest below (YOU + CLAUDE CODE, 20-30 min)
  ├── Use `br add` for each bead in Part 2 below
  ├── Or: feed the bead manifest to Claude Code and have it batch-create via `br`
  ├── Depends on: STEP 2
  └── Output: 37 beads in bv with dependency edges

STEP 4: Validate bead DAG (YOU, 5 min)
  ├── `bv --robot-triage` — verify no orphan beads, no cycles
  ├── `bv --robot-plan` — verify critical path makes sense
  ├── `bv --pages` — generate static site to visually inspect DAG
  ├── Depends on: STEP 3
  └── Output: validated bead graph

STEP 5: GCP setup (YOU, 15 min — can overlap with STEP 3)
  ├── Create or select Google Cloud project
  ├── Enable APIs: Cloud Run, Firestore API, Google Calendar API
  ├── Create Firestore database (native mode) in the project
  ├── Get Gemini API key from Google AI Studio
  ├── VERIFY model name resolves: test with a quick API call to gemini-2.5-flash-native-audio-preview-12-2025
  ├── Create OAuth 2.0 credentials for Calendar
  ├── Authorize test Google account, store refresh token
  ├── Create .env.local with ALL env vars from README §Environment variables:
  │   GEMINI_API_KEY, GEMINI_MODEL, GOOGLE_CLOUD_PROJECT, FIRESTORE_DATABASE_ID,
  │   GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI, NEXT_PUBLIC_APP_URL
  ├── Depends on: STEP 2
  └── Output: working credentials in .env.local, verified API key + model name

STEP 6: GDG signup (YOU, 3 min — can overlap with anything)
  ├── https://gdg.community.dev/ → create profile
  ├── No dependencies
  └── Output: public GDG profile URL

STEP 7: Set up ntm swarm session (YOU, 5 min)
  ├── Start agent-mail server: `am`
  ├── `ntm spawn eureka-canvas --cc=N --cod=M --gmi=K`
  │   (agent count depends on your available subscriptions/tokens)
  ├── Depends on: STEP 4 (beads validated), STEP 5 (.env.local ready)
  └── Output: tmux session with agent panes, ready to execute

STEP 8: BEGIN SWARMING
  ├── Each agent: reads AGENTS.md → `bv --robot-triage` → claim → implement → done
  ├── Depends on: STEP 7
  └── The swarm starts here. Everything below is agent work.
```

**Total pre-swarm time: ~40-50 minutes** (with GCP setup overlapping bead creation)

**Critical path: STEP 1 → 2 → 3 → 4 → 7 → 8 (~35 min)**

---

## PART 2: BEAD MANIFEST

Every bead needed to build, demo, and submit Eureka Canvas. Feed these to `br add` or have Claude Code batch-create them.

### Naming Convention

- `SC-*` Scaffold
- `AU-*` Audio Pipeline
- `CU-*` Canvas UI
- `BE-*` Backend Infrastructure
- `EX-*` External Integrations
- `IN-*` Integration (wiring tracks together)
- `DY-*` Deployment
- `DL-*` Deliverables (non-code)
- `DM-*` Demo Recording

### The Beads

---

#### SC-1: Project Scaffold

**Labels:** scaffold, critical-path
**Depends on:** nothing
**Description:** Create the full Next.js project skeleton.
- `package.json` with deps: `next`, `react`, `react-dom`, `@google/genai`, `d3-force`, `firebase-admin`, `googleapis`, `ws`, `uuid`, `@types/*`
- `tsconfig.json` (strict)
- `next.config.mjs`
- `.env.example` (all vars from README §Environment variables)
- `.gitignore`
- Directory structure matching README §Repository structure (all dirs, empty index files)
- Copy `spec.md` and `README.md` to repo root
- Basic `app/page.tsx` with "Eureka Canvas" placeholder

**Acceptance:** `npm install` succeeds. `npm run dev` shows placeholder page. Directory structure matches README.

---

#### AU-1: AudioWorklet Capture Processor

**Labels:** audio, critical-path
**Depends on:** SC-1
**Description:** Implement the browser-side audio capture per spec §10.1.
- AudioWorklet processor file (`public/audio-processor.js` or similar)
- Captures mic at system sample rate (typically 48kHz, Float32)
- Downsamples to 16kHz
- Converts Float32 → Int16 (little-endian)
- Posts PCM chunks to main thread via MessagePort
- Main thread wrapper class: `AudioCapture` with `start()`, `stop()`, `onChunk(callback)`
- Tab visibility handler (resume AudioContext on re-focus, spec §10.2)

**Acceptance:** Calling `start()` captures mic audio. `onChunk` fires with Int16 ArrayBuffers at 16kHz. Console log confirms chunk size and rate.

---

#### AU-2: Backend WebSocket Server

**Labels:** audio, backend, critical-path
**Depends on:** SC-1
**Description:** Create the Node.js WebSocket server that will proxy between browser and Gemini. Per spec §5.1.
- Express or raw HTTP server in `app/api/` or standalone server file
- WebSocket upgrade handler (use `ws` library)
- Accept browser connections
- Message types: `audio_in` (browser→backend PCM), `audio_out` (backend→browser PCM), `tool_result` (canvas state updates), `canvas_update` (drag events from frontend)
- Health check endpoint
- Environment variable loading from `.env.local`

**Acceptance:** Server starts on `npm run dev`. Browser can open WebSocket connection. Ping/pong works.

---

#### AU-3: Gemini Live API Session

**Labels:** audio, critical-path
**Depends on:** AU-2
**Description:** Connect the backend to Gemini Live API per spec §5.2.
- Use `@google/genai` SDK
- `apiVersion: 'v1alpha'`
- Full session config from spec §5.2 (system prompt, tools as BLOCKING per AGENTS.md Rule 3, proactiveAudio, thinkingConfig, transcription, sessionResumption, slidingWindow, speechConfig with Kore voice, silenceDurationMs: 700)
- **VERIFY MODEL NAME** `gemini-2.5-flash-native-audio-preview-12-2025` resolves. If not, check docs and update.
- Tool declarations for: `create_card`, `move_artifact`, `update_artifact`, `create_calendar_event`, `start_research_job` (all BLOCKING — no `behavior: NON_BLOCKING`, per AGENTS.md Rule 3)
- Session event handlers: `toolCall`, `audioData`, `interrupted`, `turnComplete`, `inputTranscription`, `outputTranscription`
- Session resumption on disconnect

**Acceptance:** Backend successfully opens Live API WebSocket. Session is created with all config. Tool declarations are accepted. `console.log` confirms session is active.

---

#### AU-4: Audio Proxy Pipeline

**Labels:** audio, critical-path
**Depends on:** AU-1, AU-3
**Description:** Wire browser audio → backend → Gemini and Gemini → backend → browser. Per spec §5.3.
- Browser sends 16kHz Int16 PCM chunks via WebSocket to backend
- Backend forwards to Gemini as `realtimeInput` with `mimeType: 'audio/pcm;rate=16000'`
- Gemini returns 24kHz Int16 PCM audio
- Backend proxies audio chunks to browser via WebSocket
- Browser playback: AudioContext at system default rate, resample 24kHz→system rate, queue and play via AudioBufferSourceNode
- Interruption: when user starts speaking, stop playback, clear queue

**Acceptance:** Speak into mic → Gemini responds → audio plays back through speakers. Interruption stops playback. Verify round-trip works with a simple "Hello, what's your name?" test.

---

#### AU-5: Transcription Display

**Labels:** audio, ui
**Depends on:** AU-4
**Description:** Wire input/output transcriptions to the frontend per spec §10.3.
- Backend forwards transcription events from Gemini to browser via WebSocket
- `TranscriptPanel.tsx` component shows running transcript
- Input transcription (user) and output transcription (agent) styled differently
- Auto-scroll to latest

**Acceptance:** Speaking shows user transcript. Agent responses show agent transcript. Panel auto-scrolls.

---

#### CU-1: Canvas Container

**Labels:** canvas, ui
**Depends on:** SC-1
**Description:** Create the pannable, zoomable canvas per spec §11.
- `Canvas.tsx` component
- Absolutely-positioned container with CSS transforms for pan/zoom
- Mouse drag to pan, scroll wheel to zoom
- Coordinate system: (0,0) at viewport center, spec §8.2
- Dark theme default (background color, subtle grid optional)
- Render children (artifact cards) at their (x, y) positions

**Acceptance:** Empty canvas renders. Can pan and zoom. Coordinate system verified: a div at (0,0) appears at viewport center.

---

#### CU-2: ArtifactCard Component

**Labels:** canvas, ui
**Depends on:** SC-1
**Description:** Card rendering component per spec §11.
- `ArtifactCard.tsx`
- Props: `id`, `title`, `body`, `tags`, `status`, `x`, `y`, `ghostState`
- Status colors: `default` (neutral), `risk` (red accent), `question` (yellow), `done` (green), `synthesis` (purple dashed, spec §11.1.1)
- Tag chips rendered below body
- Card dimensions: ~200-280px wide, height auto
- Draggable (fires `onDragEnd` with new position)
- `data-id` attribute for DOM manipulation by force layout

**Acceptance:** Render a card with mock data at (100, 100). Card shows title, body, tags, correct status color. Card is draggable.

---

#### CU-3: Ghost Card Animation

**Labels:** canvas, ui
**Depends on:** CU-2
**Description:** Ghost → solid animation per spec §11.1.
- CSS class `.artifact-card--ghost`: 30% opacity, shimmer pulse animation, slight blur
- CSS class `.artifact-card--solid`: 100% opacity, drop shadow, 200ms transition
- When card first renders: start in ghost state
- After 300ms: transition to solid state
- Each card has independent 300ms timer (not synchronized across cards)

**Acceptance:** Creating a card shows ghost state for 300ms then smoothly transitions to solid. Multiple cards created in rapid succession each have their own independent animation.

---

#### CU-4: Synthesis Card CSS

**Labels:** canvas, ui
**Depends on:** CU-2
**Description:** Visual treatment for synthesis cards per spec §11.1.1.
- CSS for `status: "synthesis"`: 2px dashed purple border, subtle gradient background, soft glow
- "✦ Synthesis" label above title (small, uppercase, purple)
- Must be distinct from all other status types at a glance

**Acceptance:** A card with `status: "synthesis"` renders with dashed border, glow, and label. Visually distinct from default cards.

---

#### CU-5: SVG Edge Rendering

**Labels:** canvas, ui
**Depends on:** CU-1, CU-2
**Description:** Dependency arrows between cards per spec §8.4 and §9 (Edge data model).
- `DagEdge.tsx` component
- SVG overlay on canvas
- Draw arrow from source card center to target card center
- Arrow style: subtle, semi-transparent, with small arrowhead
- Update positions when cards move (force layout or drag)
- Edge data: `{ from_artifact_id, to_artifact_id, type }`

**Acceptance:** Given two cards and an edge between them, an SVG arrow renders connecting them. Arrow updates when cards are repositioned.

---

#### CU-6: Force-Directed Layout

**Labels:** canvas, ui, demo-critical
**Depends on:** CU-1, CU-2
**Description:** d3-force semantic clustering per spec §11.2.
- Import `forceSimulation`, `forceCollide`, `forceManyBody`, `forceCenter`, `forceLink` from d3-force
- Configuration from spec §11.2 code example
- `forceCenter(0, 0)` with strength 0.02
- Semantic edges from shared tags, near_artifact hints, group membership (spec §11.2 `buildSemanticEdges`)
- **Direct DOM manipulation during simulation ticks** (not React state updates per tick)
- Sync positions to React state only after simulation settles (alpha < 0.01) or 2-second freeze
- `alphaDecay(0.05)` for fast settling
- Ghost cards excluded from simulation until solidified (300ms delay)
- Expose `addNode()`, `removeNode()`, `reheat()` methods

**Acceptance:** Add 5 cards with shared tags via mock data. Cards cluster by tag similarity. Layout settles within 2 seconds. No visible jitter after settling. Adding a new card reheats simulation and it re-settles.

---

#### CU-7: Canvas Replay UI

**Labels:** canvas, ui, demo-critical
**Depends on:** CU-1, CU-2
**Description:** Timeline scrubber for state snapshot playback per spec §11.3.
- `CanvasReplay.tsx` component
- Timeline scrubber at bottom of canvas
- Accepts array of `{ timestamp, artifacts }` snapshots
- Dragging scrubber interpolates card positions between snapshots
- Cards that don't exist at a given timestamp fade in/out
- Play button for auto-playback at configurable speed (fast for demo: 10 seconds for full session)
- Speed controls (1x, 2x, 5x, 10x)

**Acceptance:** Given 10 mock snapshots, scrubber plays through them. Cards appear/disappear/move smoothly. 10-second full replay works.

---

#### CU-8: Connection Status Indicator

**Labels:** canvas, ui
**Depends on:** CU-1
**Description:** WebSocket connection state indicator per spec §5.5.
- Small indicator in canvas corner
- States: Connecting (pulsing amber), Connected (green), Reconnecting (amber), Error (red with message)
- Driven by WebSocket connection state

**Acceptance:** Indicator shows correct state as WebSocket connects, disconnects, and reconnects.

---

#### CU-9: Controls Component

**Labels:** canvas, ui
**Depends on:** SC-1
**Description:** Mic button, text input fallback, basic controls.
- `Controls.tsx`
- Mic toggle button (start/stop audio capture)
- Text input field (for typed messages as fallback)
- Visual mic state: recording (red pulse), not recording (default)

**Acceptance:** Mic button toggles recording state. Text input sends message via WebSocket.

---

#### BE-1: Firestore CRUD

**Labels:** backend
**Depends on:** SC-1
**Description:** Workspace and artifact persistence per spec §9.
- `lib/firestore/` module
- `firebase-admin` SDK initialization
- Functions: `createWorkspace()`, `getWorkspace()`, `createArtifact()`, `updateArtifact()`, `getArtifacts()`, `createEdge()`, `getEdges()`
- Data models match spec §9 exactly
- Timestamps as Firestore server timestamps
- **Convert Firestore Timestamps to ISO strings before returning to tool responses** (spec §7.1 note about non-serializable values)

**Acceptance:** Can create a workspace, add artifacts, retrieve them. Firestore console shows correct data structure.

---

#### BE-2: Tool Executor Framework

**Labels:** backend, critical-path
**Depends on:** AU-3, BE-1
**Description:** Receive tool calls from Gemini, validate, execute, return results. Per spec §7.1.
- When Gemini emits a `toolCall` event, parse the function name and arguments
- Route to the appropriate handler (create_card, move_artifact, etc.)
- Validate required parameters
- Execute handler (writes to Firestore)
- **Return result object directly to SDK — do NOT JSON.stringify()** (spec §7.1 critical note)
- Send tool response back to Live API session via `session.sendToolResponse()`
- Notify frontend of canvas change via WebSocket
- Record state snapshot for replay (spec §11.3)

**Acceptance:** When Gemini calls `create_card`, the executor: validates args, writes to Firestore, returns result to Gemini, notifies frontend. Tool response includes `artifact_id` and `position`.

---

#### BE-3: create_card Handler

**Labels:** backend, critical-path
**Depends on:** BE-2
**Description:** Implement the `create_card` tool per spec §7.2.
- Parameters: `title`, `body`, `tags`, `status`, `placement`, `near_artifact_id`
- Calculate initial position from `placement` hint (viewport_center → 0,0; below_last → last card y + offset; near_artifact → near referenced card; auto_layout → let force handle it)
- Write artifact to Firestore with `created_by: "agent"`
- Return `{ artifact_id, status: "created", position: { x, y } }`
- Notify frontend to render ghost card
- Increment artifact count, check phase thresholds (synthesis trigger)

**Acceptance:** Gemini calls create_card → artifact appears in Firestore → frontend receives notification → ghost card renders and solidifies.

---

#### BE-4: move_artifact Handler

**Labels:** backend
**Depends on:** BE-2
**Description:** Implement the `move_artifact` tool per spec §7.2.
- Parameters: `artifact_id`, `placement`, `near_artifact_id`, `x`, `y`
- Calculate new position from placement hint
- Update artifact position in Firestore
- Return `{ artifact_id, status: "moved", position: { x, y } }`
- Notify frontend

**Acceptance:** Gemini calls move_artifact → position updates in Firestore → frontend moves card.

---

#### BE-5: update_artifact Handler

**Labels:** backend
**Depends on:** BE-2
**Description:** Implement the `update_artifact` tool per spec §7.2.
- Parameters: `artifact_id`, `title`, `body`, `status`
- Update specified fields in Firestore
- Return `{ artifact_id, status: "updated" }`

**Acceptance:** Gemini calls update_artifact → fields update in Firestore → frontend re-renders card.

---

#### BE-6: Canvas State Injection

**Labels:** backend
**Depends on:** BE-2
**Description:** Format and inject [CANVAS_STATE] into Live API session per spec §8.2 and §8.3.
- Function: `injectCanvasState(session, artifacts, edges)`
- Format: spec §8.2 text format
- Injection triggers per spec §8.3: after each tool call, after user drag, after layout settle, every 30s if changed
- Use `session.sendClientContent()` with `role: 'user'` (spec §8.4 code example)
- Track last-injected state to avoid redundant injections

**Acceptance:** After a tool call, canvas state is injected into the session. Format matches spec §8.2.

---

#### BE-7: Drag Detection → Context Injection + Edge Creation

**Labels:** backend, demo-critical
**Depends on:** BE-2, BE-1
**Description:** When user drags a card near another card, inject context and create edge. Per spec §8.4.
- Frontend sends drag-end event with card ID, new position
- Backend computes distance to nearest card
- If distance < 80px (proximity threshold): inject `[CANVAS_UPDATE]` context per spec §8.4 code example, with `turnComplete: true` (agent should respond)
- If distance >= 80px: inject simple position update with `turnComplete: false`
- When agent responds with confirmation, create edge in Firestore and notify frontend to render SVG arrow

**Acceptance:** Drag card A near card B (within 80px). Agent receives context injection. Agent responds acknowledging relationship. SVG edge appears. Drag card to empty space: silent position update, no agent response.

---

#### BE-8: Topology Analysis

**Labels:** backend, demo-critical
**Depends on:** BE-1, CU-6
**Description:** Compute cluster density and isolation after force layout settles. Per spec §8.6.
- Implement `computeTopology(artifacts)` from spec §8.6 code example
- Tight cluster: cards within 100px
- Isolate: card >400px from nearest neighbor
- Format as `[TOPOLOGY_ANALYSIS]` text (spec §8.6 format)
- Inject via `sendClientContent()` after force layout settle
- Only inject if topology changed since last injection
- Minimum interval: 5 seconds

**Acceptance:** With 5+ cards on canvas after force layout settles, topology analysis is computed and injected. Agent receives and can reference cluster insights in speech.

---

#### BE-9: Synthesis Trigger

**Labels:** backend, demo-critical
**Depends on:** BE-3
**Description:** After 5+ cards and user pause, inject synthesis prompt per spec §11.1.1.
- Track artifact count
- When count >= 5 and user has been silent for 2+ seconds (no audio input for 2000ms):
  - Inject `[SYSTEM]` synthesis prompt per spec §11.1.1 code example
  - Only inject once per threshold crossing (don't re-trigger on every pause)
- The agent will (hopefully) create a synthesis card in response

**Acceptance:** After creating 5 cards and pausing, the synthesis prompt is injected. Agent creates a card with `status: "synthesis"`.

---

#### BE-10: State Snapshot Recording

**Labels:** backend
**Depends on:** BE-1, BE-2
**Description:** Record canvas state snapshots for replay per spec §11.3.
- On every tool call completion, user drag, or layout settle:
  - Deep clone current artifacts array
  - Push `{ timestamp, artifacts, trigger }` to replay buffer (in-memory array)
  - Also write to Firestore `snapshots` subcollection
- Expose `getSnapshots()` for frontend replay

**Acceptance:** After a sequence of tool calls and drags, snapshot array contains ordered state history. Snapshots are in Firestore.

---

#### EX-1: Google Calendar Integration

**Labels:** external
**Depends on:** BE-2
**Description:** Implement `create_calendar_event` tool per spec §7.4.
- `lib/google/calendar.ts`
- OAuth2 client using `googleapis` library
- Accept refresh token from env vars
- `createEvent(title, start_time, end_time, description, attendees)` → Google Calendar API
- Tool handler: receives tool call from Gemini, calls `createEvent()`, returns `{ event_id, status: "created", calendar_link }`
- Also create a confirmation card on the canvas (artifact with type `calendar_event`)

**Acceptance:** Gemini calls create_calendar_event → event appears in Google Calendar → confirmation card appears on canvas.
**Note:** Requires human checkpoint (STEP 5 in pre-swarm DAG) for OAuth credentials.

---

#### EX-2: Research Runner

**Labels:** external, demo-critical
**Depends on:** SC-1
**Description:** Background research with Google Search grounding per spec §7.3.
- `lib/google/research.ts`
- Separate `generateContent` call (NOT Live API) with `tools: [{ googleSearch: {} }]`
- Accept `topic` and `context` parameters
- Parse response for key findings and sources
- Return structured result: `{ summary, findings: [], sources: [] }`

**Acceptance:** Call `runResearch("Q2 API launch risks")` → returns structured findings with real search results.

---

#### EX-3: Research Job Integration

**Labels:** external, demo-critical
**Depends on:** EX-2, BE-2, BE-3
**Description:** Wire research into the Live API session per spec §7.3 background execution flow.
- `start_research_job` tool handler:
  1. Create job node artifact on canvas (status: running, pulsing animation)
  2. Return `{ job_id, artifact_id, status: "started" }` to Gemini immediately (blocking tool — model waits)
  3. After tool response, kick off async research via EX-2
  4. When results return, inject `sendClientContent` with the `[SYSTEM]` research results prompt (spec §7.3 step 3)
  5. The prompt instructs agent to create individual cards for each finding (research cascading)
  6. Update job node status to "complete"

**Acceptance:** Say "research compliance requirements" → job node appears with pulse → research runs → results inject → agent announces findings and creates multiple cards → cards enter force simulation.

---

#### IN-1: End-to-End Audio + Tool Wiring

**Labels:** integration, critical-path
**Depends on:** AU-4, BE-2, BE-3, CU-1, CU-2, CU-3
**Description:** Wire everything together for the core loop: speak → Gemini → tool calls → cards on canvas.
- Browser audio capture → WebSocket → backend → Gemini Live API
- Gemini tool calls → tool executor → Firestore → frontend notification
- Frontend receives notification → renders ghost card → solidifies
- Gemini audio response → backend → browser → playback
- System prompt loaded, agent responds as Eureka persona
- Verify: speaking about a project creates cards SILENTLY (no agent narration during creation)

**Acceptance:** Speak naturally about 3 project concerns. 3+ ghost cards appear silently during speech. Cards solidify. After pause, agent speaks one brief insight. No card creation narration.

---

#### IN-2: Force Layout Integration

**Labels:** integration, demo-critical
**Depends on:** IN-1, CU-6
**Description:** Wire force layout to live artifacts (not just mock data).
- When new cards are created via tool calls, add them to the force simulation
- Semantic edges derived from tags/placement hints
- Cards cluster after creation
- Ghost cards excluded until solidified (300ms delay)

**Acceptance:** Speak and create 5 cards. Cards settle into semantic clusters via force layout. Related cards (shared tags) cluster together.

---

#### IN-3: Drag + Edge Integration

**Labels:** integration, demo-critical
**Depends on:** IN-1, BE-7, CU-5
**Description:** Wire drag detection through to edge creation.
- User drags card → frontend sends drag event → backend injects context → agent responds → edge created → SVG arrow renders
- Force layout considers edges (forceLink)

**Acceptance:** Drag card A near card B. Agent says something like "I see the connection." SVG arrow appears. Cards are now linked in force layout.

---

#### IN-4: Topology + Synthesis Integration

**Labels:** integration, demo-critical
**Depends on:** IN-2, BE-8, BE-9
**Description:** Wire topology analysis and synthesis triggering to live canvas.
- After force layout settles with 5+ cards → topology computed → injected → agent can reference clusters
- After 5+ cards and user pause → synthesis prompt → agent creates synthesis card

**Acceptance:** Create 5+ cards. After layout settles, agent references cluster insights. After a pause, a synthesis card appears with a genuine cross-card insight.

---

#### IN-5: Research + Calendar Integration

**Labels:** integration, demo-critical
**Depends on:** IN-1, EX-1, EX-3
**Description:** Wire research and calendar through the live session.
- Say "research [topic]" → start_research_job fires → job node appears → research runs → results cascade as cards
- Say "schedule a meeting for [time]" → create_calendar_event fires → event created → confirmation card

**Acceptance:** Full research flow works end-to-end. Full calendar flow works end-to-end.

---

#### IN-6: Replay Integration

**Labels:** integration, demo-critical
**Depends on:** IN-2, BE-10, CU-7
**Description:** Wire live state snapshots to the replay UI.
- Every tool call, drag, and layout settle creates a snapshot
- Replay scrubber shows actual session history
- Playing back compresses session into time-lapse

**Acceptance:** After a full interaction (5+ cards, research, calendar), hit replay. 10-second time-lapse shows entire session evolution.

---

#### DY-1: Cloud Run Deployment

**Labels:** deployment
**Depends on:** IN-1 (at minimum — deploy once core works)
**Description:** Deploy to Cloud Run per spec §5.6.
- Create Dockerfile (or use buildpacks)
- `gcloud run deploy eureka-canvas --source . --region us-central1 --allow-unauthenticated --timeout=3600 --min-instances=1`
- Set env vars for Gemini API key, model name, GCP project
- Verify WebSocket works on deployed instance

**Acceptance:** App is accessible at Cloud Run URL. Audio pipeline works on deployed version.

---

#### DY-2: Deploy Script

**Labels:** deployment, bonus
**Depends on:** DY-1
**Description:** Create `scripts/deploy.sh` for bonus points (+0.2).
- Automated deployment script per spec §2.4
- Sets env vars, runs gcloud deploy command
- Include in repo root

**Acceptance:** `./scripts/deploy.sh` deploys the app to Cloud Run successfully.

---

#### DL-1: Architecture Diagram

**Labels:** deliverable, demo-critical
**Depends on:** SC-1
**Description:** Create polished architecture diagram per spec §13.2 Shot 6.
- SVG or PNG, color-coded
- Shows: Browser → Cloud Run → Gemini Live API → Firestore → Calendar → Search grounding
- Label SDK features: Proactive Audio, FunctionResponseScheduling, thinking budget, session resumption
- Save to `public/architecture.png`

**Acceptance:** Clean, professional diagram that a judge can understand in 5 seconds. All SDK features labeled.

---

#### DL-2: Blog Post

**Labels:** deliverable, bonus
**Depends on:** IN-1 (need to have built something to write about)
**Description:** Write and publish blog post on dev.to per spec §14.1.
- Title: "The Text Box Is Dead: What We Learned Building a Spatial Thinking Partner with Gemini"
- ~700 words following spec §14.1 structure
- **MUST include:** "This project was created for the purposes of entering the Gemini Live Agent Challenge hackathon."
- **MUST include:** #GeminiLiveAgentChallenge hashtag
- Embed architecture diagram
- Link to GitHub repo
- Must be PUBLIC (not unlisted/draft)
- +0.6 bonus points

**Acceptance:** Published on dev.to. Public URL. Contains required language and hashtag.

---

#### DL-3: Devpost Text Description

**Labels:** deliverable
**Depends on:** IN-1
**Description:** Write the Devpost submission text per spec §14.2.
- 200-300 words
- Hit all keywords from spec §14.2 keyword list
- Summary of features, technologies, data sources, learnings

**Acceptance:** 200-300 words. All spec §14.2 keywords present.

---

#### DM-1: Record Demo Video

**Labels:** demo, human-only
**Depends on:** IN-1, DY-1, DL-1 (minimum: core loop working + deployed + architecture diagram; IN-6 replay is ideal but not blocking)
**Description:** Record demo per spec §13.2 shot-by-shot script.
- Record each of 7 shots separately, 3 takes each
- Splice best takes with clean cuts
- Text overlays naming SDK features (bottom-right, each segment)
- Target 3:30, under 4:00
- Upload to YouTube as PUBLIC

**Acceptance:** Video is public on YouTube. ≤4 minutes. Shows all features from spec §13.3 checklist.

---

#### DM-2: Cloud Proof Recording

**Labels:** demo, human-only
**Depends on:** DY-1
**Description:** Record Cloud deployment proof SEPARATE from demo per Devpost rules.
- Screen recording of Cloud Run console showing deployed service
- OR: Firestore console showing workspace data
- 15-30 seconds

**Acceptance:** Short recording showing GCP console with deployed service.

---

#### DM-3: Submit to Devpost

**Labels:** submission, human-only
**Depends on:** DM-1, DM-2, DL-1, DL-2, DL-3
**Description:** Complete and submit the Devpost entry.
- Select category: Live Agents
- Text description (DL-3)
- Public GitHub repo URL
- Demo video YouTube URL (DM-1)
- Cloud proof link/upload (DM-2)
- Architecture diagram upload (DL-1)
- Blog post URL (DL-2)
- GDG profile link
- Deploy script mention
- Testing Instructions field (judges-only: mic permissions, desktop Chrome, known limitations, fallback note about demo video)
- **SUBMIT BY 4:00 PM PDT**

**Acceptance:** Submission is complete on Devpost. All required fields filled. All links public and working.

---

## PART 3: DEPENDENCY GRAPH (VISUAL)

```
                              SC-1 (Scaffold)
                             /    |    \      \
                           /      |      \      \
                         /        |        \      \
                  AU-1   AU-2    CU-1..9   BE-1   DL-1
                  (Mic)  (WS)   (Canvas)   (DB)   (Arch)
                    \     |     [parallel]   |
                     \    |                  |
                      AU-3 (Live API)        |
                       |                     |
                      AU-4 (Audio Proxy)     |
                      / |                    |
                 AU-5   |              BE-2 (Tool Executor)
                (Txn)   |             / | \  \     \
                        |       BE-3  4  5  6  BE-7  BE-9
                        |      (card) .. .. (state) (drag) (synth)
                        |        |                    |
                        |      BE-8 (topology)  BE-10 (snapshots)
                        |        |
                    EX-1  EX-2  EX-3
                   (Cal)  (Res) (ResJob)
                        \   |   /
                         \  |  /
                    IN-1 (End-to-End Wiring)
                   / |  \    \
              IN-2  IN-3  IN-5  IN-4
             (Force)(Drag)(R+C) (Topo+Synth)
                \    |    /    /
                 \   |   /   /
                  IN-6 (Replay)
                    |
                  DY-1 (Deploy)
                    |
                  DY-2 (deploy.sh)
                    |
               DM-1 (Record Demo)     DL-2 (Blog)     DL-3 (Devpost Text)
                  \                      |                /
                   \                     |               /
                    DM-2 (Cloud Proof)   |              /
                      \                  |             /
                       \                 |            /
                        DM-3 (Submit to Devpost)
```

### Parallel Tracks Summary

At maximum parallelism (after SC-1 completes), agents can work on:

| Track | Beads | Can Start After |
|-------|-------|-----------------|
| Audio Pipeline | AU-1 → AU-2 → AU-3 → AU-4 → AU-5 | SC-1 |
| Canvas UI | CU-1 through CU-9 (mostly parallel) | SC-1 |
| Backend Infra | BE-1, then BE-2→BE-10 after AU-3 | SC-1 (BE-1), AU-3 (BE-2+) |
| External | EX-1, EX-2 (parallel) | SC-1 (EX-2), BE-2 (EX-1, EX-3) |
| Deliverables | DL-1 | SC-1 |
| Integration | IN-1 through IN-6 | AU-4 + BE-3 + CU-1-3 minimum |

**Maximum simultaneous agents (after SC-1):** 8-10 (all CU-* beads + AU-1 + AU-2 + BE-1 + EX-2 + DL-1)

---

## PART 4: SWARM LAUNCH CHECKLIST

Before sending the first `ntm` command, verify:

- [ ] `git init` done, AGENTS.md + spec.md + README.md in repo
- [ ] All beads created via `br` (run `bv --robot-triage` to verify)
- [ ] `bv --robot-plan` shows no cycles and critical path is SC-1 → AU-* → IN-1 → DM-1
- [ ] `.env.local` has working `GEMINI_API_KEY`
- [ ] `.env.local` has `GOOGLE_CLOUD_PROJECT` and Firestore credentials
- [ ] `.env.local` has Calendar OAuth credentials (or marked as TODO for human checkpoint)
- [ ] `agent-mail` server is running (`am`)
- [ ] `ntm spawn eureka-canvas --cc=N` is ready

### Recommended Agent Allocation (first wave)

| Agent | First Bead | Track |
|-------|-----------|-------|
| Agent 1 | SC-1 (scaffold) | Critical path — everyone waits for this |
| Agent 2 | (wait for SC-1) → AU-1 | Audio pipeline |
| Agent 3 | (wait for SC-1) → CU-1 | Canvas container |
| Agent 4 | (wait for SC-1) → CU-2 + CU-3 | Card component + ghost animation |
| Agent 5 | (wait for SC-1) → BE-1 | Firestore CRUD |
| Agent 6 | (wait for SC-1) → DL-1 | Architecture diagram |
| Agent 7 | (wait for SC-1) → EX-2 | Research runner |

After SC-1 completes (10-15 min), all agents can claim their first beads simultaneously.

### Time Budget

| Phase | Allocated | Deadline |
|-------|-----------|----------|
| Pre-swarm setup | 40 min | Now + 40 min |
| Swarming: Foundation + Canvas + Backend | 3 hours | ~3 hours before deadline |
| Swarming: Integration | 1.5 hours | ~1.5 hours before deadline |
| Demo recording + editing | 1.5 hours | ~4:00 PM PDT |
| Submission | 15 min | 4:00 PM PDT (1-hour buffer) |
| **Hard deadline** | — | **5:00 PM PDT** |

**If integration beads aren't done 3 hours before deadline:** Switch to P0-only fallback demo (spec §13.1). Cards at fixed positions, no force layout animation, skip replay. Still competitive.

---

## PART 5: HOW TO CREATE THE BEADS

For each bead in Part 2, run:

```bash
br add \
  --title "AU-1: AudioWorklet Capture Processor" \
  --description "Implement browser-side audio capture per spec §10.1. AudioWorklet processor that captures at system rate, downsamples to 16kHz, converts Float32→Int16. See AGENTS.md Rule 2. Acceptance: onChunk fires with Int16 ArrayBuffers at 16kHz." \
  --label audio \
  --label critical-path \
  --depends-on SC-1
```

**Or batch-create:** Copy the bead manifest (Part 2) into a prompt for Claude Code:

> "Read the bead manifest in this file. For each bead, run `br add` with the title, a concise description referencing the spec section, the labels, and the depends-on edges. Use the bead IDs (SC-1, AU-1, etc.) as the bead identifiers."

This is the fastest path — a single Claude Code agent can create all 37 beads in 5-10 minutes.

---

**The plan is complete. Execute the pre-swarm DAG. Then let the agents fly.**

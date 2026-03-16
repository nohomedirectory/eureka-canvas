#!/usr/bin/env bash
set -euo pipefail
cd /home/ubuntu/eureka-canvas

echo "=== Creating all 37 beads ==="

# SC-1: Project Scaffold
SC1=$(br create --silent --title "SC-1: Project Scaffold" \
  --priority P0 \
  --labels "scaffold,critical-path" \
  --description "Create the full Next.js project skeleton.
- package.json with deps: next, react, react-dom, @google/genai, d3-force, firebase-admin, googleapis, ws, uuid, @types/*
- tsconfig.json (strict)
- next.config.mjs
- .env.example (all vars from README §Environment variables)
- .gitignore
- Directory structure matching README §Repository structure (all dirs, empty index files)
- Copy spec.md and README.md to repo root
- Basic app/page.tsx with 'Eureka Canvas' placeholder

Acceptance: npm install succeeds. npm run dev shows placeholder page. Directory structure matches README.")
echo "SC-1 = $SC1"

# AU-1: AudioWorklet Capture Processor
AU1=$(br create --silent --title "AU-1: AudioWorklet Capture Processor" \
  --priority P0 \
  --labels "audio,critical-path" \
  --description "Implement browser-side audio capture per spec §10.1.
- AudioWorklet processor file (public/audio-processor.js or similar)
- Captures mic at system sample rate (typically 48kHz, Float32)
- Downsamples to 16kHz
- Converts Float32 → Int16 (little-endian)
- Posts PCM chunks to main thread via MessagePort
- Main thread wrapper class: AudioCapture with start(), stop(), onChunk(callback)
- Tab visibility handler (resume AudioContext on re-focus, spec §10.2)

Acceptance: Calling start() captures mic audio. onChunk fires with Int16 ArrayBuffers at 16kHz. Console log confirms chunk size and rate.")
echo "AU-1 = $AU1"

# AU-2: Backend WebSocket Server
AU2=$(br create --silent --title "AU-2: Backend WebSocket Server" \
  --priority P0 \
  --labels "audio,backend,critical-path" \
  --description "Create the Node.js WebSocket server that proxies between browser and Gemini. Per spec §5.1.
- Express or raw HTTP server in app/api/ or standalone server file
- WebSocket upgrade handler (use ws library)
- Accept browser connections
- Message types: audio_in (browser→backend PCM), audio_out (backend→browser PCM), tool_result (canvas state updates), canvas_update (drag events from frontend)
- Health check endpoint
- Environment variable loading from .env.local

Acceptance: Server starts on npm run dev. Browser can open WebSocket connection. Ping/pong works.")
echo "AU-2 = $AU2"

# AU-3: Gemini Live API Session
AU3=$(br create --silent --title "AU-3: Gemini Live API Session" \
  --priority P0 \
  --labels "audio,critical-path" \
  --description "Connect the backend to Gemini Live API per spec §5.2.
- Use @google/genai SDK
- apiVersion: v1alpha
- Full session config from spec §5.2 (system prompt, tools as BLOCKING per AGENTS.md Rule 3, proactiveAudio, thinkingConfig, transcription, sessionResumption, slidingWindow, speechConfig with Kore voice, silenceDurationMs: 700)
- VERIFY MODEL NAME gemini-2.5-flash-native-audio-preview-12-2025 resolves. If not, check docs and update.
- Tool declarations for: create_card, move_artifact, update_artifact, create_calendar_event, start_research_job (all BLOCKING — no behavior: NON_BLOCKING, per AGENTS.md Rule 3)
- Session event handlers: toolCall, audioData, interrupted, turnComplete, inputTranscription, outputTranscription
- Session resumption on disconnect

Acceptance: Backend successfully opens Live API WebSocket. Session is created with all config. Tool declarations are accepted. console.log confirms session is active.")
echo "AU-3 = $AU3"

# AU-4: Audio Proxy Pipeline
AU4=$(br create --silent --title "AU-4: Audio Proxy Pipeline" \
  --priority P0 \
  --labels "audio,critical-path" \
  --description "Wire browser audio → backend → Gemini and Gemini → backend → browser. Per spec §5.3.
- Browser sends 16kHz Int16 PCM chunks via WebSocket to backend
- Backend forwards to Gemini as realtimeInput with mimeType: audio/pcm;rate=16000
- Gemini returns 24kHz Int16 PCM audio
- Backend proxies audio chunks to browser via WebSocket
- Browser playback: AudioContext at system default rate, resample 24kHz→system rate, queue and play via AudioBufferSourceNode
- Interruption: when user starts speaking, stop playback, clear queue

Acceptance: Speak into mic → Gemini responds → audio plays back through speakers. Interruption stops playback. Verify round-trip works with a simple Hello test.")
echo "AU-4 = $AU4"

# AU-5: Transcription Display
AU5=$(br create --silent --title "AU-5: Transcription Display" \
  --priority P1 \
  --labels "audio,ui" \
  --description "Wire input/output transcriptions to the frontend per spec §10.3.
- Backend forwards transcription events from Gemini to browser via WebSocket
- TranscriptPanel.tsx component shows running transcript
- Input transcription (user) and output transcription (agent) styled differently
- Auto-scroll to latest

Acceptance: Speaking shows user transcript. Agent responses show agent transcript. Panel auto-scrolls.")
echo "AU-5 = $AU5"

# CU-1: Canvas Container
CU1=$(br create --silent --title "CU-1: Canvas Container" \
  --priority P0 \
  --labels "canvas,ui" \
  --description "Create the pannable, zoomable canvas per spec §11.
- Canvas.tsx component
- Absolutely-positioned container with CSS transforms for pan/zoom
- Mouse drag to pan, scroll wheel to zoom
- Coordinate system: (0,0) at viewport center, spec §8.2
- Dark theme default (background color, subtle grid optional)
- Render children (artifact cards) at their (x, y) positions

Acceptance: Empty canvas renders. Can pan and zoom. Coordinate system verified: a div at (0,0) appears at viewport center.")
echo "CU-1 = $CU1"

# CU-2: ArtifactCard Component
CU2=$(br create --silent --title "CU-2: ArtifactCard Component" \
  --priority P0 \
  --labels "canvas,ui" \
  --description "Card rendering component per spec §11.
- ArtifactCard.tsx
- Props: id, title, body, tags, status, x, y, ghostState
- Status colors: default (neutral), risk (red accent), question (yellow), done (green), synthesis (purple dashed, spec §11.1.1)
- Tag chips rendered below body
- Card dimensions: ~200-280px wide, height auto
- Draggable (fires onDragEnd with new position)
- data-id attribute for DOM manipulation by force layout

Acceptance: Render a card with mock data at (100, 100). Card shows title, body, tags, correct status color. Card is draggable.")
echo "CU-2 = $CU2"

# CU-3: Ghost Card Animation
CU3=$(br create --silent --title "CU-3: Ghost Card Animation" \
  --priority P0 \
  --labels "canvas,ui" \
  --description "Ghost → solid animation per spec §11.1.
- CSS class .artifact-card--ghost: 30% opacity, shimmer pulse animation, slight blur
- CSS class .artifact-card--solid: 100% opacity, drop shadow, 200ms transition
- When card first renders: start in ghost state
- After 300ms: transition to solid state
- Each card has independent 300ms timer (not synchronized across cards)

Acceptance: Creating a card shows ghost state for 300ms then smoothly transitions to solid. Multiple cards created in rapid succession each have their own independent animation.")
echo "CU-3 = $CU3"

# CU-4: Synthesis Card CSS
CU4=$(br create --silent --title "CU-4: Synthesis Card CSS" \
  --priority P0 \
  --labels "canvas,ui" \
  --description "Visual treatment for synthesis cards per spec §11.1.1.
- CSS for status: synthesis: 2px dashed purple border, subtle gradient background, soft glow
- Synthesis label above title (small, uppercase, purple)
- Must be distinct from all other status types at a glance

Acceptance: A card with status: synthesis renders with dashed border, glow, and label. Visually distinct from default cards.")
echo "CU-4 = $CU4"

# CU-5: SVG Edge Rendering
CU5=$(br create --silent --title "CU-5: SVG Edge Rendering" \
  --priority P0 \
  --labels "canvas,ui" \
  --description "Dependency arrows between cards per spec §8.4 and §9 (Edge data model).
- DagEdge.tsx component
- SVG overlay on canvas
- Draw arrow from source card center to target card center
- Arrow style: subtle, semi-transparent, with small arrowhead
- Update positions when cards move (force layout or drag)
- Edge data: { from_artifact_id, to_artifact_id, type }

Acceptance: Given two cards and an edge between them, an SVG arrow renders connecting them. Arrow updates when cards are repositioned.")
echo "CU-5 = $CU5"

# CU-6: Force-Directed Layout
CU6=$(br create --silent --title "CU-6: Force-Directed Layout" \
  --priority P0 \
  --labels "canvas,ui,demo-critical" \
  --description "d3-force semantic clustering per spec §11.2.
- Import forceSimulation, forceCollide, forceManyBody, forceCenter, forceLink from d3-force
- Configuration from spec §11.2 code example
- forceCenter(0, 0) with strength 0.02
- Semantic edges from shared tags, near_artifact hints, group membership (spec §11.2 buildSemanticEdges)
- Direct DOM manipulation during simulation ticks (not React state updates per tick)
- Sync positions to React state only after simulation settles (alpha < 0.01) or 2-second freeze
- alphaDecay(0.05) for fast settling
- Ghost cards excluded from simulation until solidified (300ms delay)
- Expose addNode(), removeNode(), reheat() methods

Acceptance: Add 5 cards with shared tags via mock data. Cards cluster by tag similarity. Layout settles within 2 seconds. No visible jitter after settling. Adding a new card reheats simulation and it re-settles.")
echo "CU-6 = $CU6"

# CU-7: Canvas Replay UI
CU7=$(br create --silent --title "CU-7: Canvas Replay UI" \
  --priority P0 \
  --labels "canvas,ui,demo-critical" \
  --description "Timeline scrubber for state snapshot playback per spec §11.3.
- CanvasReplay.tsx component
- Timeline scrubber at bottom of canvas
- Accepts array of { timestamp, artifacts } snapshots
- Dragging scrubber interpolates card positions between snapshots
- Cards that dont exist at a given timestamp fade in/out
- Play button for auto-playback at configurable speed (fast for demo: 10 seconds for full session)
- Speed controls (1x, 2x, 5x, 10x)

Acceptance: Given 10 mock snapshots, scrubber plays through them. Cards appear/disappear/move smoothly. 10-second full replay works.")
echo "CU-7 = $CU7"

# CU-8: Connection Status Indicator
CU8=$(br create --silent --title "CU-8: Connection Status Indicator" \
  --priority P1 \
  --labels "canvas,ui" \
  --description "WebSocket connection state indicator per spec §5.5.
- Small indicator in canvas corner
- States: Connecting (pulsing amber), Connected (green), Reconnecting (amber), Error (red with message)
- Driven by WebSocket connection state

Acceptance: Indicator shows correct state as WebSocket connects, disconnects, and reconnects.")
echo "CU-8 = $CU8"

# CU-9: Controls Component
CU9=$(br create --silent --title "CU-9: Controls Component" \
  --priority P0 \
  --labels "canvas,ui" \
  --description "Mic button, text input fallback, basic controls.
- Controls.tsx
- Mic toggle button (start/stop audio capture)
- Text input field (for typed messages as fallback)
- Visual mic state: recording (red pulse), not recording (default)

Acceptance: Mic button toggles recording state. Text input sends message via WebSocket.")
echo "CU-9 = $CU9"

# BE-1: Firestore CRUD
BE1=$(br create --silent --title "BE-1: Firestore CRUD" \
  --priority P0 \
  --labels "backend" \
  --description "Workspace and artifact persistence per spec §9.
- lib/firestore/ module
- firebase-admin SDK initialization
- Functions: createWorkspace(), getWorkspace(), createArtifact(), updateArtifact(), getArtifacts(), createEdge(), getEdges()
- Data models match spec §9 exactly
- Timestamps as Firestore server timestamps
- Convert Firestore Timestamps to ISO strings before returning to tool responses (spec §7.1 note about non-serializable values)

Acceptance: Can create a workspace, add artifacts, retrieve them. Firestore console shows correct data structure.")
echo "BE-1 = $BE1"

# BE-2: Tool Executor Framework
BE2=$(br create --silent --title "BE-2: Tool Executor Framework" \
  --priority P0 \
  --labels "backend,critical-path" \
  --description "Receive tool calls from Gemini, validate, execute, return results. Per spec §7.1.
- When Gemini emits a toolCall event, parse the function name and arguments
- Route to the appropriate handler (create_card, move_artifact, etc.)
- Validate required parameters
- Execute handler (writes to Firestore)
- Return result object directly to SDK — do NOT JSON.stringify() (spec §7.1 critical note)
- Send tool response back to Live API session via session.sendToolResponse()
- Notify frontend of canvas change via WebSocket
- Record state snapshot for replay (spec §11.3)

Acceptance: When Gemini calls create_card, the executor: validates args, writes to Firestore, returns result to Gemini, notifies frontend. Tool response includes artifact_id and position.")
echo "BE-2 = $BE2"

# BE-3: create_card Handler
BE3=$(br create --silent --title "BE-3: create_card Handler" \
  --priority P0 \
  --labels "backend,critical-path" \
  --description "Implement the create_card tool per spec §7.2.
- Parameters: title, body, tags, status, placement, near_artifact_id
- Calculate initial position from placement hint (viewport_center → 0,0; below_last → last card y + offset; near_artifact → near referenced card; auto_layout → let force handle it)
- Write artifact to Firestore with created_by: agent
- Return { artifact_id, status: created, position: { x, y } }
- Notify frontend to render ghost card
- Increment artifact count, check phase thresholds (synthesis trigger)

Acceptance: Gemini calls create_card → artifact appears in Firestore → frontend receives notification → ghost card renders and solidifies.")
echo "BE-3 = $BE3"

# BE-4: move_artifact Handler
BE4=$(br create --silent --title "BE-4: move_artifact Handler" \
  --priority P0 \
  --labels "backend" \
  --description "Implement the move_artifact tool per spec §7.2.
- Parameters: artifact_id, placement, near_artifact_id, x, y
- Calculate new position from placement hint
- Update artifact position in Firestore
- Return { artifact_id, status: moved, position: { x, y } }
- Notify frontend

Acceptance: Gemini calls move_artifact → position updates in Firestore → frontend moves card.")
echo "BE-4 = $BE4"

# BE-5: update_artifact Handler
BE5=$(br create --silent --title "BE-5: update_artifact Handler" \
  --priority P1 \
  --labels "backend" \
  --description "Implement the update_artifact tool per spec §7.2.
- Parameters: artifact_id, title, body, status
- Update specified fields in Firestore
- Return { artifact_id, status: updated }

Acceptance: Gemini calls update_artifact → fields update in Firestore → frontend re-renders card.")
echo "BE-5 = $BE5"

# BE-6: Canvas State Injection
BE6=$(br create --silent --title "BE-6: Canvas State Injection" \
  --priority P0 \
  --labels "backend" \
  --description "Format and inject [CANVAS_STATE] into Live API session per spec §8.2 and §8.3.
- Function: injectCanvasState(session, artifacts, edges)
- Format: spec §8.2 text format
- Injection triggers per spec §8.3: after each tool call, after user drag, after layout settle, every 30s if changed
- Use session.sendClientContent() with role: user (spec §8.4 code example)
- Track last-injected state to avoid redundant injections

Acceptance: After a tool call, canvas state is injected into the session. Format matches spec §8.2.")
echo "BE-6 = $BE6"

# BE-7: Drag Detection → Context Injection + Edge Creation
BE7=$(br create --silent --title "BE-7: Drag Detection → Context Injection + Edge Creation" \
  --priority P0 \
  --labels "backend,demo-critical" \
  --description "When user drags a card near another card, inject context and create edge. Per spec §8.4.
- Frontend sends drag-end event with card ID, new position
- Backend computes distance to nearest card
- If distance < 80px (proximity threshold): inject [CANVAS_UPDATE] context per spec §8.4 code example, with turnComplete: true (agent should respond)
- If distance >= 80px: inject simple position update with turnComplete: false
- When agent responds with confirmation, create edge in Firestore and notify frontend to render SVG arrow

Acceptance: Drag card A near card B (within 80px). Agent receives context injection. Agent responds acknowledging relationship. SVG edge appears. Drag card to empty space: silent position update, no agent response.")
echo "BE-7 = $BE7"

# BE-8: Topology Analysis
BE8=$(br create --silent --title "BE-8: Topology Analysis" \
  --priority P0 \
  --labels "backend,demo-critical" \
  --description "Compute cluster density and isolation after force layout settles. Per spec §8.6.
- Implement computeTopology(artifacts) from spec §8.6 code example
- Tight cluster: cards within 100px
- Isolate: card >400px from nearest neighbor
- Format as [TOPOLOGY_ANALYSIS] text (spec §8.6 format)
- Inject via sendClientContent() after force layout settle
- Only inject if topology changed since last injection
- Minimum interval: 5 seconds

Acceptance: With 5+ cards on canvas after force layout settles, topology analysis is computed and injected. Agent receives and can reference cluster insights in speech.")
echo "BE-8 = $BE8"

# BE-9: Synthesis Trigger
BE9=$(br create --silent --title "BE-9: Synthesis Trigger" \
  --priority P0 \
  --labels "backend,demo-critical" \
  --description "After 5+ cards and user pause, inject synthesis prompt per spec §11.1.1.
- Track artifact count
- When count >= 5 and user has been silent for 2+ seconds (no audio input for 2000ms):
  - Inject [SYSTEM] synthesis prompt per spec §11.1.1 code example
  - Only inject once per threshold crossing (dont re-trigger on every pause)
- The agent will (hopefully) create a synthesis card in response

Acceptance: After creating 5 cards and pausing, the synthesis prompt is injected. Agent creates a card with status: synthesis.")
echo "BE-9 = $BE9"

# BE-10: State Snapshot Recording
BE10=$(br create --silent --title "BE-10: State Snapshot Recording" \
  --priority P0 \
  --labels "backend" \
  --description "Record canvas state snapshots for replay per spec §11.3.
- On every tool call completion, user drag, or layout settle:
  - Deep clone current artifacts array
  - Push { timestamp, artifacts, trigger } to replay buffer (in-memory array)
  - Also write to Firestore snapshots subcollection
- Expose getSnapshots() for frontend replay

Acceptance: After a sequence of tool calls and drags, snapshot array contains ordered state history. Snapshots are in Firestore.")
echo "BE-10 = $BE10"

# EX-1: Google Calendar Integration
EX1=$(br create --silent --title "EX-1: Google Calendar Integration" \
  --priority P0 \
  --labels "external" \
  --description "Implement create_calendar_event tool per spec §7.4.
- lib/google/calendar.ts
- OAuth2 client using googleapis library
- Accept refresh token from env vars
- createEvent(title, start_time, end_time, description, attendees) → Google Calendar API
- Tool handler: receives tool call from Gemini, calls createEvent(), returns { event_id, status: created, calendar_link }
- Also create a confirmation card on the canvas (artifact with type calendar_event)

Acceptance: Gemini calls create_calendar_event → event appears in Google Calendar → confirmation card appears on canvas.
Note: Requires human checkpoint (STEP 5 in pre-swarm DAG) for OAuth credentials.")
echo "EX-1 = $EX1"

# EX-2: Research Runner
EX2=$(br create --silent --title "EX-2: Research Runner" \
  --priority P0 \
  --labels "external,demo-critical" \
  --description "Background research with Google Search grounding per spec §7.3.
- lib/google/research.ts
- Separate generateContent call (NOT Live API) with tools: [{ googleSearch: {} }]
- Accept topic and context parameters
- Parse response for key findings and sources
- Return structured result: { summary, findings: [], sources: [] }

Acceptance: Call runResearch('Q2 API launch risks') → returns structured findings with real search results.")
echo "EX-2 = $EX2"

# EX-3: Research Job Integration
EX3=$(br create --silent --title "EX-3: Research Job Integration" \
  --priority P0 \
  --labels "external,demo-critical" \
  --description "Wire research into the Live API session per spec §7.3 background execution flow.
- start_research_job tool handler:
  1. Create job node artifact on canvas (status: running, pulsing animation)
  2. Return { job_id, artifact_id, status: started } to Gemini immediately (blocking tool — model waits)
  3. After tool response, kick off async research via EX-2
  4. When results return, inject sendClientContent with the [SYSTEM] research results prompt (spec §7.3 step 3)
  5. The prompt instructs agent to create individual cards for each finding (research cascading)
  6. Update job node status to complete

Acceptance: Say research compliance requirements → job node appears with pulse → research runs → results inject → agent announces findings and creates multiple cards → cards enter force simulation.")
echo "EX-3 = $EX3"

# IN-1: End-to-End Audio + Tool Wiring
IN1=$(br create --silent --title "IN-1: End-to-End Audio + Tool Wiring" \
  --priority P0 \
  --labels "integration,critical-path" \
  --description "Wire everything together for the core loop: speak → Gemini → tool calls → cards on canvas.
- Browser audio capture → WebSocket → backend → Gemini Live API
- Gemini tool calls → tool executor → Firestore → frontend notification
- Frontend receives notification → renders ghost card → solidifies
- Gemini audio response → backend → browser → playback
- System prompt loaded, agent responds as Eureka persona
- Verify: speaking about a project creates cards SILENTLY (no agent narration during creation)

Acceptance: Speak naturally about 3 project concerns. 3+ ghost cards appear silently during speech. Cards solidify. After pause, agent speaks one brief insight. No card creation narration.")
echo "IN-1 = $IN1"

# IN-2: Force Layout Integration
IN2=$(br create --silent --title "IN-2: Force Layout Integration" \
  --priority P0 \
  --labels "integration,demo-critical" \
  --description "Wire force layout to live artifacts (not just mock data).
- When new cards are created via tool calls, add them to the force simulation
- Semantic edges derived from tags/placement hints
- Cards cluster after creation
- Ghost cards excluded until solidified (300ms delay)

Acceptance: Speak and create 5 cards. Cards settle into semantic clusters via force layout. Related cards (shared tags) cluster together.")
echo "IN-2 = $IN2"

# IN-3: Drag + Edge Integration
IN3=$(br create --silent --title "IN-3: Drag + Edge Integration" \
  --priority P0 \
  --labels "integration,demo-critical" \
  --description "Wire drag detection through to edge creation.
- User drags card → frontend sends drag event → backend injects context → agent responds → edge created → SVG arrow renders
- Force layout considers edges (forceLink)

Acceptance: Drag card A near card B. Agent says something like I see the connection. SVG arrow appears. Cards are now linked in force layout.")
echo "IN-3 = $IN3"

# IN-4: Topology + Synthesis Integration
IN4=$(br create --silent --title "IN-4: Topology + Synthesis Integration" \
  --priority P0 \
  --labels "integration,demo-critical" \
  --description "Wire topology analysis and synthesis triggering to live canvas.
- After force layout settles with 5+ cards → topology computed → injected → agent can reference clusters
- After 5+ cards and user pause → synthesis prompt → agent creates synthesis card

Acceptance: Create 5+ cards. After layout settles, agent references cluster insights. After a pause, a synthesis card appears with a genuine cross-card insight.")
echo "IN-4 = $IN4"

# IN-5: Research + Calendar Integration
IN5=$(br create --silent --title "IN-5: Research + Calendar Integration" \
  --priority P0 \
  --labels "integration,demo-critical" \
  --description "Wire research and calendar through the live session.
- Say research [topic] → start_research_job fires → job node appears → research runs → results cascade as cards
- Say schedule a meeting for [time] → create_calendar_event fires → event created → confirmation card

Acceptance: Full research flow works end-to-end. Full calendar flow works end-to-end.")
echo "IN-5 = $IN5"

# IN-6: Replay Integration
IN6=$(br create --silent --title "IN-6: Replay Integration" \
  --priority P0 \
  --labels "integration,demo-critical" \
  --description "Wire live state snapshots to the replay UI.
- Every tool call, drag, and layout settle creates a snapshot
- Replay scrubber shows actual session history
- Playing back compresses session into time-lapse

Acceptance: After a full interaction (5+ cards, research, calendar), hit replay. 10-second time-lapse shows entire session evolution.")
echo "IN-6 = $IN6"

# DY-1: Cloud Run Deployment
DY1=$(br create --silent --title "DY-1: Cloud Run Deployment" \
  --priority P0 \
  --labels "deployment" \
  --description "Deploy to Cloud Run per spec §5.6.
- Create Dockerfile (or use buildpacks)
- gcloud run deploy eureka-canvas --source . --region us-central1 --allow-unauthenticated --timeout=3600 --min-instances=1
- Set env vars for Gemini API key, model name, GCP project
- Verify WebSocket works on deployed instance

Acceptance: App is accessible at Cloud Run URL. Audio pipeline works on deployed version.")
echo "DY-1 = $DY1"

# DY-2: Deploy Script
DY2=$(br create --silent --title "DY-2: Deploy Script" \
  --priority P1 \
  --labels "deployment,bonus" \
  --description "Create scripts/deploy.sh for bonus points (+0.2).
- Automated deployment script per spec §2.4
- Sets env vars, runs gcloud deploy command
- Include in repo root

Acceptance: ./scripts/deploy.sh deploys the app to Cloud Run successfully.")
echo "DY-2 = $DY2"

# DL-1: Architecture Diagram
DL1=$(br create --silent --title "DL-1: Architecture Diagram" \
  --priority P0 \
  --labels "deliverable,demo-critical" \
  --description "Create polished architecture diagram per spec §13.2 Shot 6.
- SVG or PNG, color-coded
- Shows: Browser → Cloud Run → Gemini Live API → Firestore → Calendar → Search grounding
- Label SDK features: Proactive Audio, FunctionResponseScheduling, thinking budget, session resumption
- Save to public/architecture.png

Acceptance: Clean, professional diagram that a judge can understand in 5 seconds. All SDK features labeled.")
echo "DL-1 = $DL1"

# DL-2: Blog Post
DL2=$(br create --silent --title "DL-2: Blog Post" \
  --priority P1 \
  --labels "deliverable,bonus" \
  --description "Write and publish blog post on dev.to per spec §14.1.
- Title: The Text Box Is Dead: What We Learned Building a Spatial Thinking Partner with Gemini
- ~700 words following spec §14.1 structure
- MUST include: This project was created for the purposes of entering the Gemini Live Agent Challenge hackathon.
- MUST include: #GeminiLiveAgentChallenge hashtag
- Embed architecture diagram
- Link to GitHub repo
- Must be PUBLIC (not unlisted/draft)
- +0.6 bonus points

Acceptance: Published on dev.to. Public URL. Contains required language and hashtag.")
echo "DL-2 = $DL2"

# DL-3: Devpost Text Description
DL3=$(br create --silent --title "DL-3: Devpost Text Description" \
  --priority P0 \
  --labels "deliverable" \
  --description "Write the Devpost submission text per spec §14.2.
- 200-300 words
- Hit all keywords from spec §14.2 keyword list
- Summary of features, technologies, data sources, learnings

Acceptance: 200-300 words. All spec §14.2 keywords present.")
echo "DL-3 = $DL3"

# DM-1: Record Demo Video
DM1=$(br create --silent --title "DM-1: Record Demo Video" \
  --priority P0 \
  --labels "demo,human-only" \
  --description "Record demo per spec §13.2 shot-by-shot script.
- Record each of 7 shots separately, 3 takes each
- Splice best takes with clean cuts
- Text overlays naming SDK features (bottom-right, each segment)
- Target 3:30, under 4:00
- Upload to YouTube as PUBLIC

Acceptance: Video is public on YouTube. ≤4 minutes. Shows all features from spec §13.3 checklist.")
echo "DM-1 = $DM1"

# DM-2: Cloud Proof Recording
DM2=$(br create --silent --title "DM-2: Cloud Proof Recording" \
  --priority P0 \
  --labels "demo,human-only" \
  --description "Record Cloud deployment proof SEPARATE from demo per Devpost rules.
- Screen recording of Cloud Run console showing deployed service
- OR: Firestore console showing workspace data
- 15-30 seconds

Acceptance: Short recording showing GCP console with deployed service.")
echo "DM-2 = $DM2"

# DM-3: Submit to Devpost
DM3=$(br create --silent --title "DM-3: Submit to Devpost" \
  --priority P0 \
  --labels "submission,human-only" \
  --description "Complete and submit the Devpost entry.
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
- SUBMIT BY 4:00 PM PDT

Acceptance: Submission is complete on Devpost. All required fields filled. All links public and working.")
echo "DM-3 = $DM3"

echo ""
echo "=== All 37 beads created ==="
echo ""
echo "=== Adding dependencies ==="

# SC-1 has no dependencies

# AU-1 depends on SC-1
br dep add "$AU1" "$SC1"
echo "AU-1 → SC-1"

# AU-2 depends on SC-1
br dep add "$AU2" "$SC1"
echo "AU-2 → SC-1"

# AU-3 depends on AU-2
br dep add "$AU3" "$AU2"
echo "AU-3 → AU-2"

# AU-4 depends on AU-1, AU-3
br dep add "$AU4" "$AU1"
br dep add "$AU4" "$AU3"
echo "AU-4 → AU-1, AU-3"

# AU-5 depends on AU-4
br dep add "$AU5" "$AU4"
echo "AU-5 → AU-4"

# CU-1 depends on SC-1
br dep add "$CU1" "$SC1"
echo "CU-1 → SC-1"

# CU-2 depends on SC-1
br dep add "$CU2" "$SC1"
echo "CU-2 → SC-1"

# CU-3 depends on CU-2
br dep add "$CU3" "$CU2"
echo "CU-3 → CU-2"

# CU-4 depends on CU-2
br dep add "$CU4" "$CU2"
echo "CU-4 → CU-2"

# CU-5 depends on CU-1, CU-2
br dep add "$CU5" "$CU1"
br dep add "$CU5" "$CU2"
echo "CU-5 → CU-1, CU-2"

# CU-6 depends on CU-1, CU-2
br dep add "$CU6" "$CU1"
br dep add "$CU6" "$CU2"
echo "CU-6 → CU-1, CU-2"

# CU-7 depends on CU-1, CU-2
br dep add "$CU7" "$CU1"
br dep add "$CU7" "$CU2"
echo "CU-7 → CU-1, CU-2"

# CU-8 depends on CU-1
br dep add "$CU8" "$CU1"
echo "CU-8 → CU-1"

# CU-9 depends on SC-1
br dep add "$CU9" "$SC1"
echo "CU-9 → SC-1"

# BE-1 depends on SC-1
br dep add "$BE1" "$SC1"
echo "BE-1 → SC-1"

# BE-2 depends on AU-3, BE-1
br dep add "$BE2" "$AU3"
br dep add "$BE2" "$BE1"
echo "BE-2 → AU-3, BE-1"

# BE-3 depends on BE-2
br dep add "$BE3" "$BE2"
echo "BE-3 → BE-2"

# BE-4 depends on BE-2
br dep add "$BE4" "$BE2"
echo "BE-4 → BE-2"

# BE-5 depends on BE-2
br dep add "$BE5" "$BE2"
echo "BE-5 → BE-2"

# BE-6 depends on BE-2
br dep add "$BE6" "$BE2"
echo "BE-6 → BE-2"

# BE-7 depends on BE-2, BE-1
br dep add "$BE7" "$BE2"
br dep add "$BE7" "$BE1"
echo "BE-7 → BE-2, BE-1"

# BE-8 depends on BE-1, CU-6
br dep add "$BE8" "$BE1"
br dep add "$BE8" "$CU6"
echo "BE-8 → BE-1, CU-6"

# BE-9 depends on BE-3
br dep add "$BE9" "$BE3"
echo "BE-9 → BE-3"

# BE-10 depends on BE-1, BE-2
br dep add "$BE10" "$BE1"
br dep add "$BE10" "$BE2"
echo "BE-10 → BE-1, BE-2"

# EX-1 depends on BE-2
br dep add "$EX1" "$BE2"
echo "EX-1 → BE-2"

# EX-2 depends on SC-1
br dep add "$EX2" "$SC1"
echo "EX-2 → SC-1"

# EX-3 depends on EX-2, BE-2, BE-3
br dep add "$EX3" "$EX2"
br dep add "$EX3" "$BE2"
br dep add "$EX3" "$BE3"
echo "EX-3 → EX-2, BE-2, BE-3"

# IN-1 depends on AU-4, BE-2, BE-3, CU-1, CU-2, CU-3
br dep add "$IN1" "$AU4"
br dep add "$IN1" "$BE2"
br dep add "$IN1" "$BE3"
br dep add "$IN1" "$CU1"
br dep add "$IN1" "$CU2"
br dep add "$IN1" "$CU3"
echo "IN-1 → AU-4, BE-2, BE-3, CU-1, CU-2, CU-3"

# IN-2 depends on IN-1, CU-6
br dep add "$IN2" "$IN1"
br dep add "$IN2" "$CU6"
echo "IN-2 → IN-1, CU-6"

# IN-3 depends on IN-1, BE-7, CU-5
br dep add "$IN3" "$IN1"
br dep add "$IN3" "$BE7"
br dep add "$IN3" "$CU5"
echo "IN-3 → IN-1, BE-7, CU-5"

# IN-4 depends on IN-2, BE-8, BE-9
br dep add "$IN4" "$IN2"
br dep add "$IN4" "$BE8"
br dep add "$IN4" "$BE9"
echo "IN-4 → IN-2, BE-8, BE-9"

# IN-5 depends on IN-1, EX-1, EX-3
br dep add "$IN5" "$IN1"
br dep add "$IN5" "$EX1"
br dep add "$IN5" "$EX3"
echo "IN-5 → IN-1, EX-1, EX-3"

# IN-6 depends on IN-2, BE-10, CU-7
br dep add "$IN6" "$IN2"
br dep add "$IN6" "$BE10"
br dep add "$IN6" "$CU7"
echo "IN-6 → IN-2, BE-10, CU-7"

# DY-1 depends on IN-1
br dep add "$DY1" "$IN1"
echo "DY-1 → IN-1"

# DY-2 depends on DY-1
br dep add "$DY2" "$DY1"
echo "DY-2 → DY-1"

# DL-1 depends on SC-1
br dep add "$DL1" "$SC1"
echo "DL-1 → SC-1"

# DL-2 depends on IN-1
br dep add "$DL2" "$IN1"
echo "DL-2 → IN-1"

# DL-3 depends on IN-1
br dep add "$DL3" "$IN1"
echo "DL-3 → IN-1"

# DM-1 depends on IN-1, DY-1, DL-1
br dep add "$DM1" "$IN1"
br dep add "$DM1" "$DY1"
br dep add "$DM1" "$DL1"
echo "DM-1 → IN-1, DY-1, DL-1"

# DM-2 depends on DY-1
br dep add "$DM2" "$DY1"
echo "DM-2 → DY-1"

# DM-3 depends on DM-1, DM-2, DL-1, DL-2, DL-3
br dep add "$DM3" "$DM1"
br dep add "$DM3" "$DM2"
br dep add "$DM3" "$DL1"
br dep add "$DM3" "$DL2"
br dep add "$DM3" "$DL3"
echo "DM-3 → DM-1, DM-2, DL-1, DL-2, DL-3"

echo ""
echo "=== All dependencies wired ==="
echo ""
echo "=== Bead ID Mapping ==="
echo "SC-1  = $SC1"
echo "AU-1  = $AU1"
echo "AU-2  = $AU2"
echo "AU-3  = $AU3"
echo "AU-4  = $AU4"
echo "AU-5  = $AU5"
echo "CU-1  = $CU1"
echo "CU-2  = $CU2"
echo "CU-3  = $CU3"
echo "CU-4  = $CU4"
echo "CU-5  = $CU5"
echo "CU-6  = $CU6"
echo "CU-7  = $CU7"
echo "CU-8  = $CU8"
echo "CU-9  = $CU9"
echo "BE-1  = $BE1"
echo "BE-2  = $BE2"
echo "BE-3  = $BE3"
echo "BE-4  = $BE4"
echo "BE-5  = $BE5"
echo "BE-6  = $BE6"
echo "BE-7  = $BE7"
echo "BE-8  = $BE8"
echo "BE-9  = $BE9"
echo "BE-10 = $BE10"
echo "EX-1  = $EX1"
echo "EX-2  = $EX2"
echo "EX-3  = $EX3"
echo "IN-1  = $IN1"
echo "IN-2  = $IN2"
echo "IN-3  = $IN3"
echo "IN-4  = $IN4"
echo "IN-5  = $IN5"
echo "IN-6  = $IN6"
echo "DY-1  = $DY1"
echo "DY-2  = $DY2"
echo "DL-1  = $DL1"
echo "DL-2  = $DL2"
echo "DL-3  = $DL3"
echo "DM-1  = $DM1"
echo "DM-2  = $DM2"
echo "DM-3  = $DM3"

echo ""
echo "=== DONE. Run 'br list' or 'br ready' to verify ==="

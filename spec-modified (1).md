# Eureka Canvas — Product & Technical Specification

**Version:** 2.2
**Date:** March 16, 2026
**Status:** Final build-spec
**Submission category:** Live Agents

---

## 1. Executive summary

Eureka Canvas is a live, screen-aware workspace where Gemini perceives a visual canvas, structures rough thoughts into spatial artifacts, runs background research, and takes real actions through Google Calendar.

The core thesis:

> Move beyond the text box by turning conversation into a persistent visual thinking space that the agent can perceive and manipulate.

The key insight comes from cognitive science: humans think better when they externalize their thoughts into space. Whiteboards, war rooms, architect models — spatial arrangement isn't decoration, it's part of the thinking process. Eureka Canvas makes the AI a participant in this spatial cognition. The agent doesn't just answer questions — it helps you *see the shape of your thinking.*

The hackathon deliverable is a single focused product with one story:

1. The user speaks naturally.
2. The agent automatically crystallizes thoughts into spatial artifacts — silently, without being asked — controlled by the system prompt and FunctionResponseScheduling, with Proactive Audio as an optional enhancement.
3. The user interrupts and redirects in real time.
4. The agent reasons over what is visible on-screen.
5. Background research runs while the user keeps working.
6. The agent creates a Google Calendar event.
7. The canvas can be replayed as a time-lapse of thought evolution.

---

## 2. Challenge positioning

### 2.1 Fit

Eureka Canvas maps directly to the challenge criteria:

- **Beyond the text box:** The primary surface is a spatial canvas, not a chat thread. Chat is 1-dimensional (time-ordered). Canvas is 2-dimensional (spatial relationships). This is the same jump from command line to GUI.
- **See / hear / speak:** Live voice, screen-grounded understanding, structured artifact creation.
- **Live and interruptible:** The user can redirect mid-stream and the workspace adapts. Ghost cards make the agent's thinking visible and interruptible at the artifact level.
- **Google-native:** Gemini Live API (Proactive Audio, thinking budget, FunctionResponseScheduling) + Cloud Run + Firestore + Google Calendar + Google Search grounding.

### 2.2 Category

**Live Agents.** The strongest differentiator is a real-time multimodal workspace agent with voice interaction, spatial grounding, and interruptibility.

### 2.3 Judging strategy

| Criterion | Weight | Strategy |
|-----------|--------|----------|
| Innovation & Multimodal UX | 40% | Auto-crystallization via Proactive Audio, ghost cards, force-directed layout, topology analysis, synthesis cards, bidirectional spatial communication (drag-as-command), canvas replay, spatial grounding, voice persona, interruption handling |
| Technical Implementation | 30% | Deep GenAI SDK usage (Proactive Audio, thinking budget, FunctionResponseScheduling, Google Search grounding, dynamic system instruction mutation), Cloud Run + Firestore, validated tool calls, research cascading, error handling |
| Demo & Presentation | 30% | Segment-recorded video with thesis framing, canvas replay closer, polished architecture diagram, Cloud deployment proof |

### 2.4 Bonus points

| Bonus | Points | Plan |
|-------|--------|------|
| Blog post (dev.to) | +0.6 | Publish "The Text Box Is Dead: What We Learned Building a Spatial Thinking Partner with Gemini" |
| Automated deploy script | +0.2 | `scripts/deploy.sh` in repository |
| GDG membership | +0.2 | Active profile linked in submission |
| **Total** | **+1.0** | On a 5-point scale, this is a 20% score boost |

---

## 3. Product vision

### 3.1 Vision

A live cognitive workspace where humans and agents think together in space.

### 3.2 Experience goal

The product should feel immediate, collaborative, alive, and unmistakably beyond a chatbot. The canvas is not a display — it is a shared mind.

### 3.3 The defining moment

The user starts thinking out loud about a project. Without being asked, the canvas begins structuring their thoughts into spatial artifacts. Cards appear silently — the agent doesn't speak because the system prompt forbids narrating tool calls, and FunctionResponseScheduling controls audio generation after each tool response. The cards cluster semantically via force-directed physics. The agent didn't respond to the user — it thought alongside them. That is the moment the judge feels: "This is what comes after chat."

---

## 4. Goals and non-goals

### 4.1 Goals

1. Provide a pannable, zoomable canvas workspace with force-directed semantic layout.
2. Support live voice interaction via Gemini Live API with native audio and Proactive Audio.
3. Support interruptible agent responses with graceful pivots.
4. Let Gemini perceive visible canvas content through structured state and on-demand snapshots.
5. Let Gemini create, move, group, and transform artifacts via tool calls with FunctionResponseScheduling (SILENT / WHEN_IDLE / INTERRUPT).
6. Support one background job type (research) with visible status and Google Search grounding.
7. Support one Google Workspace action (Calendar event creation).
8. Persist workspace state in Firestore with canvas replay capability.
9. Deploy on Google Cloud Run.
10. Produce a demo video showing all of the above in a coherent narrative, ending with canvas replay time-lapse.

### 4.2 Non-goals

- Multi-agent orchestration or agent marketplace
- More than one Google Workspace integration
- Long-term user memory or personalization
- Video or image generation
- Multi-user collaboration
- Mobile-optimized responsive design

### 4.3 Scope tiers

**P0 — Must ship (the demo depends on these):**
1. Canvas with artifact rendering and drag support
2. Voice session plumbing (audio capture, playback, transcript)
3. Live API function-call loop with FunctionResponseScheduling
   - **Note:** Force-directed layout (P1 #1) is also required for the demo golden path (see strategy doc and §13.2 Shot 2). Treat it as a hard P0 dependency for demo recording even though it is categorized as P1 for MVP functionality.
4. `create_card`, `move_artifact`, `create_calendar_event` tools
5. Proactive Audio enabled in session config
6. Agent persona and silent crystallization behavior
7. Card creation animations (300ms fade-in with ghost card preview)
8. Firestore persistence (save/restore workspace)
9. Cloud Run deployment with `--timeout=3600 --min-instances=1`
10. Demo video + architecture diagram + Cloud proof
11. User drag detection → context injection with edge creation (bidirectional spatial communication) — promoted from P1; this is the second most important demo moment after auto-crystallization
12. Synthesis cards — agent-generated cross-card insights with `status: "synthesis"` and dashed-border rendering, triggered after 5+ cards and a user pause
13. Synthesis card trigger injection — backend injects `[SYSTEM]` synthesis prompt via `sendClientContent` at 5+ card threshold (required to actually trigger P0 #12; does not depend on P1 dynamic system instruction mutation)

**P1 — High value if time permits:**
1. Force-directed semantic layout (d3-force or custom spring simulation)
2. `group_artifacts` tool
3. `start_research_job` with background execution, Google Search grounding, and result injection — with research cascading (results become multiple cards that enter force simulation)
4. Canvas snapshot sent as image context for spatial references
5. Canvas replay (state snapshot timeline with scrubber animation)
6. Thought topology analysis — after force layout settles, compute cluster density and inject `[TOPOLOGY_ANALYSIS]` so the agent derives insight from the spatial structure it created
7. Dynamic system instruction mutation — phase-based prompt updates via `clientContent` at artifact count thresholds (creation-heavy → synthesis → critical refinement)
8. Light/dark theme toggle
9. Blog post + deploy script + GDG bonus

**P2 — Only if P0 and P1 are polished:**
1. Multi-view transformations (timeline view, priority view, dependency view)
2. `delete_artifact` and single-level undo
3. Thinking budget indicator (brief visible reasoning flashes on canvas)
4. Task DAG rendering with SVG edges
5. Research job node with streaming progress

---

## 5. System architecture

### 5.1 Architecture pattern: Server proxy

```
Browser ←WebSocket→ Cloud Run (Node.js) ←WebSocket→ Gemini Live API
                     Cloud Run (Node.js) ←HTTP→ Firestore
                     Cloud Run (Node.js) ←HTTP→ Google Calendar API
                     Cloud Run (Node.js) ←HTTP→ Gemini API (research jobs + Google Search grounding)
```

**Rationale:** Eureka Canvas is a tool-call-heavy application. Each tool call in a server-proxy architecture executes in ~100-200ms (backend directly sends response to the Live API). In a client-direct architecture, each tool call requires a browser→backend→browser→API round trip (~300-500ms). With 5+ tool calls per interaction, server-proxy saves 1-2 seconds of perceived latency. The audio overhead of the proxy (~50-100ms) is below human perception.

### 5.2 Session management

**Model:** `gemini-2.5-flash-native-audio-preview-12-2025` (Gemini Developer API)

**Session limits:**
- Audio-only sessions: 15 minutes without context window compression
- Audio-video sessions: 2 minutes without compression
- Connection lifetime: ~10 minutes, then requires session resumption

**Design decisions:**
- Default to audio-only (15-minute limit) for the Live session
- Send canvas screenshots as inline images via `clientContent` only on-demand (not continuous `realtimeInput` video), which avoids triggering the 2-minute limit
- Enable session resumption to handle connection resets
- Enable context window compression (`slidingWindow`) for sessions exceeding 10 minutes
- **Enable Proactive Audio** so the model natively decides when to speak and when to silently act via tool calls
- **Enable thinking budget** so the model reasons before complex spatial decisions

**Session configuration:**

```javascript
import { GoogleGenAI, Modality, Behavior, FunctionResponseScheduling, EndSensitivity } from '@google/genai';

// v1alpha required for Proactive Audio and NON_BLOCKING tool behavior
const ai = new GoogleGenAI({ httpOptions: { apiVersion: 'v1alpha' } });

const config = {
  responseModalities: [Modality.AUDIO],
  systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
  tools: [{ functionDeclarations: CANVAS_TOOLS }], // See §7.2 for behavior: NON_BLOCKING on canvas tools

  // Native audio features — technical differentiators
  proactivity: { proactiveAudio: true },          // Model decides when to speak vs silently act
  thinkingConfig: { thinkingBudget: 512 },         // Visible reasoning for spatial decisions

  // Transcription and session management
  outputAudioTranscription: {},
  inputAudioTranscription: {},
  sessionResumption: {},
  contextWindowCompression: { slidingWindow: {} },

  // Voice and activity detection
  // NOTE: Do NOT set languageCode with native audio models — they auto-detect language.
  // Setting languageCode may cause errors or silent misconfiguration.
  speechConfig: {
    voiceConfig: { prebuiltVoiceConfig: { voiceName: 'Kore' } }
  },
  realtimeInputConfig: {
    automaticActivityDetection: {
      endOfSpeechSensitivity: EndSensitivity.END_SENSITIVITY_LOW,
      silenceDurationMs: 700  // Longer pause tolerance for thinking-aloud patterns. Reduce to 500 for demo.
    }
  }
};
```

**Important: Proactive Audio is a best-case-scenario feature.** Its documented behavior is to let the model proactively decide not to respond when the input content is not relevant — it is topic/relevance-based, not device-directedness detection. For example, you can instruct "only respond when the topic is about project planning" and the model will stay silent for off-topic chatter. However, it may also suppress tool calls (not just audio) for speech it deems irrelevant. The core silent crystallization behavior MUST work without Proactive Audio, using the system prompt + FunctionResponseScheduling.SILENT as the primary mechanism. If Proactive Audio suppresses tool calls during thinking-aloud, disable it and rely on the other layers.

**Important: FunctionResponseScheduling.SILENT has known limitations.** Developers have reported that NON_BLOCKING tools cause the model to generate duplicate or speculative audio in parallel with tool execution, regardless of SILENT scheduling. The model may narrate tool calls or provide speculative content before tool results arrive. Mitigations: (1) The system prompt explicitly forbids narrating tool calls. (2) If SILENT scheduling fails to suppress narration, switch canvas tools to default BLOCKING behavior — the model cannot speak while a BLOCKING tool executes, providing guaranteed silence during card creation. The trade-off is that FunctionResponseScheduling cannot be used on BLOCKING tools, but the silence is enforced by the API itself. (3) Test both NON_BLOCKING+SILENT and BLOCKING approaches early and commit to whichever works.

**Why `silenceDurationMs: 700`:** With auto-crystallization, the model should wait longer before deciding the user is done. This prevents the agent from interrupting mid-thought with audio when the user is pausing between ideas. **For demo recording, consider reducing to 500ms** to make the agent feel more responsive on camera. The user can script natural pauses during recording.

**Voice selection:** Test Kore, Charon, Puck, Aoede, and Fenrir before recording. Kore and Charon tend to be more grounded and less "helpful assistant." Use whichever sounds cleanest on the demo hardware.

### 5.2.1 Dynamic system instruction mutation *(P1)*

The Gemini Live API supports updating system instructions mid-session by sending `clientContent` with `role: "system"`. The agent's behavior should evolve as the canvas matures — aggressive creation early, synthesis in the middle, critical refinement late.

**Phase thresholds:**

| Phase | Trigger | Behavioral shift |
|-------|---------|-----------------|
| **Divergent** (0-4 cards) | Session start | "Listen for structured concepts and create cards aggressively. 3-5 cards per thought burst. Prioritize capturing everything." |
| **Convergent** (5-9 cards) | 5th card created | "The canvas has 5+ artifacts. Shift from creation to SYNTHESIS. Look for connections between existing cards. Create cards only for genuinely new concepts. Consider creating a synthesis card if cross-card insights emerge." |
| **Critical** (10+ cards) | 10th card created | "The canvas is mature. Focus on refinement, status updates, and action items. Challenge the user's assumptions. Offer research on unvalidated claims. Topology-level insights are high value." |

**Implementation:**
```javascript
// NOTE: Use session.sendClientContent() — the SDK's high-level method.
// Do NOT use session.send({ clientContent: ... }) which is the raw WebSocket transport.

function checkPhaseTransition(artifactCount) {
  const thresholds = [
    { count: 5, phase: 'convergent' },
    { count: 10, phase: 'critical' }
  ];
  for (const t of thresholds) {
    if (artifactCount >= t.count && currentPhase !== t.phase) {
      currentPhase = t.phase;
      session.sendClientContent({
        turns: {
          role: 'system',
          parts: [{ text: PHASE_PROMPTS[t.phase] }]
        },
        turnComplete: false
      });
    }
  }
}
```

The Live API merges the updated instruction with the original system prompt. Phase transitions are one-way (divergent → convergent → critical) within a session. **Note:** The Vertex AI docs confirm this feature uses `sendClientContent` with `role: "system"`. The Gemini Developer API (non-Vertex) should also support this via `clientContent` — verify during testing, as documentation is primarily Vertex AI-sourced.

### 5.3 Data flow

1. User audio enters browser, streams to Cloud Run via WebSocket.
2. Cloud Run proxies audio to Gemini Live API.
3. Gemini processes audio with Proactive Audio (decides whether to respond at all based on relevance).
4. Gemini emits audio responses (proxied to browser for playback) and/or tool calls.
5. Cloud Run executes tool calls: writes to Firestore, calls Calendar API, or spawns research jobs.
6. Cloud Run sends tool responses back to the Live API session with **FunctionResponseScheduling** (SILENT during active speech, WHEN_IDLE after pauses, INTERRUPT for urgent results). Each response includes the artifact ID of the created/modified object.
7. Cloud Run notifies the browser of canvas state changes via the same WebSocket. New cards arrive as "ghost" state (30% opacity).
8. Browser renders ghost cards, then solidifies them after 300ms. Force-directed layout adjusts positions.
9. Browser records state snapshot for canvas replay.
10. After force-directed layout settles, the backend computes cluster topology (density, isolation) and injects a `[TOPOLOGY_ANALYSIS]` context update so the model can derive emergent spatial insights. *(P1)*
11. Periodically, the backend injects a `[CANVAS_STATE]` update into the session to keep the model's spatial context current.

### 5.4 FunctionResponseScheduling strategy

**Critical: FunctionResponseScheduling (SILENT / WHEN_IDLE / INTERRUPT) only works on functions declared with `behavior: NON_BLOCKING`.** The scheduling field is ignored on blocking (default) functions. See §7.2 for which tools use which behavior.

When returning tool responses to the Live API session, use scheduling to control whether the model speaks:

```javascript
import { FunctionResponseScheduling } from '@google/genai';

// During active user speech — canvas updates silently
function silentToolResponse(toolCall, result) {
  return {
    id: toolCall.id,
    name: toolCall.name,
    response: {
      result: result,  // Pass object directly — SDK handles serialization
      scheduling: FunctionResponseScheduling.SILENT
    }
  };
}

// After user pause — model can comment on what it did
function idleToolResponse(toolCall, result) {
  return {
    id: toolCall.id,
    name: toolCall.name,
    response: {
      result: result,
      scheduling: FunctionResponseScheduling.WHEN_IDLE
    }
  };
}

// Urgent results (research complete, errors) — interrupt if needed
function interruptToolResponse(toolCall, result) {
  return {
    id: toolCall.id,
    name: toolCall.name,
    response: {
      result: result,
      scheduling: FunctionResponseScheduling.INTERRUPT
    }
  };
}
```

**NON_BLOCKING + SILENT and the hallucination/narration problem:** NON_BLOCKING tools cause a known behavior where the model generates speculative or duplicate audio in parallel with tool execution. SILENT scheduling is intended to suppress audio generation after the tool response arrives, but developers have reported that (a) the model may narrate or speculate BEFORE the tool response returns, and (b) SILENT may not fully prevent duplicate audio. The system prompt's "never narrate tool calls" instruction provides an independent mitigation layer. If testing reveals persistent narration during card creation, switch canvas tools to default BLOCKING behavior — this guarantees silence during tool execution because the model waits for the blocking response before speaking. See §5.2 for the full fallback strategy.

**BLOCKING fallback strategy:** If canvas tools use BLOCKING (default) behavior instead of NON_BLOCKING, FunctionResponseScheduling is not available (scheduling is ignored on blocking tools). However, BLOCKING provides guaranteed silence during tool execution — the model literally cannot generate audio until the tool response returns. After receiving the response, the model follows the system prompt instruction to not narrate. This is less elegant than NON_BLOCKING + SILENT but more reliable.

**Scheduling rules:**

Note: FunctionResponseScheduling applies ONLY to NON_BLOCKING tools. The Calendar and Research tools use default BLOCKING behavior — the model waits silently for their responses regardless of any scheduling parameter. If canvas tools are switched to BLOCKING as a fallback (see above), remove scheduling from their responses.
| Tool | During speech | After pause |
|------|--------------|-------------|
| `create_card` | SILENT | WHEN_IDLE |
| `move_artifact` | SILENT | WHEN_IDLE |
| `group_artifacts` | SILENT | WHEN_IDLE |
| `update_artifact` | SILENT | SILENT |
| `create_calendar_event` | N/A (BLOCKING) | N/A (BLOCKING) |
| `start_research_job` | N/A (BLOCKING) | N/A (BLOCKING) |
| Research job completion (injected via `sendClientContent`) | N/A — not a tool response | N/A — not a tool response |

**Research job result delivery:** Research results are injected via `sendClientContent`, NOT via `sendToolResponse`. This means FunctionResponseScheduling does not apply. The model decides whether to speak after receiving the context injection based on the prompt instruction ("Announce the overall results to the user"). The `[SYSTEM]` prefix and explicit instruction to announce results makes the model reliably speak — but there is no programmatic INTERRUPT control. If you need guaranteed speech, consider wrapping the research result delivery in a dummy tool call with INTERRUPT scheduling.

**Detecting "during speech" vs "after pause":** The backend tracks whether the user is currently speaking by monitoring `realtimeInput` audio chunks. If audio has been received within the last 700ms, use SILENT scheduling. Otherwise, use the default for that tool.

### 5.5 Connection health

The Live API WebSocket may fail to connect during periods of high load (e.g., the judging period when thousands of hackathon apps are being tested). The frontend must display a visible connection status indicator:

- **Connecting:** Pulsing indicator while WebSocket handshake is in progress.
- **Connected:** Green indicator; canvas is interactive.
- **Reconnecting:** Amber indicator during session resumption after a connection drop.
- **Error:** Red indicator with message: "Live API unavailable. Please refresh or try again shortly."

In the Testing Instructions (judges-only field): "If the Live API is temporarily unavailable during testing, the demo video shows all features working in a live session."

### 5.6 Cloud Run configuration

```bash
gcloud run deploy eureka-canvas \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --timeout=3600 \
  --min-instances=1 \
  --set-env-vars "GEMINI_API_KEY=$GEMINI_API_KEY,GEMINI_MODEL=gemini-2.5-flash-native-audio-preview-12-2025,GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT"
```

- `--timeout=3600`: Prevents WebSocket termination during active sessions (default is 300s).
- `--min-instances=1`: Eliminates cold-start latency during the judging period.

---

## 6. Agent persona

### Name: Eureka

### Personality

Sharp, concise, spatially-minded. Eureka thinks in space — it says things like "let me cluster these," "I'll put that near the timeline," and "those are drifting apart semantically." It never says "as an AI" or narrates its tool calls. The canvas update IS the communication.

### Behavioral modes

| Context | Behavior | Scheduling |
|---------|----------|------------|
| User listing concepts | Create cards silently (system prompt forbids narration; FunctionResponseScheduling.SILENT suppresses post-tool audio) | SILENT |
| User finishes thought (2+ sec pause) | Speak brief insight informed by topology analysis, then act | WHEN_IDLE |
| 5+ cards exist and user pauses | Consider creating a synthesis card if genuine cross-card insight exists | SILENT |
| Force layout settles with topology injection | Derive insight from cluster structure (shared root causes, isolated workstreams) | WHEN_IDLE |
| User asks direct question | Answer concisely, then offer action | WHEN_IDLE |
| User makes spatial reference | Confirm what's seen, then act: "I see the API card on the left — moving it now" | WHEN_IDLE |
| Interruption | Stop instantly. "Got it." Execute new request. Offer to resume. | SILENT (for any tool calls during pivot) |
| Background job completes | Announce findings naturally, create individual result cards that enter force simulation | INTERRUPT |
| User drags card near another card | Interpret as relationship signal — confirm and create dependency edge | WHEN_IDLE |
| User drags card to empty space | Update spatial context silently | SILENT |

### System prompt (~400 words)

```
You are Eureka, a spatial thinking partner who helps humans organize
ideas on a visual canvas through voice conversation.

IDENTITY: Sharp, concise, spatially-minded. You say "let me cluster
these" and "I'll put that near the timeline." You think in space.

NEVER say: "Sure!", "I'd be happy to help", "Great question!",
"Let me help you with that", "as an AI." Never narrate tool calls.
Never ask "Would you like me to...?" — just act.

TOOL CALL SILENCE: ABSOLUTELY NEVER describe, acknowledge, or
narrate tool calls. NEVER say "I'm creating a card" or "Let me
add that to the canvas" or "I just created..." The canvas update
IS the communication. If you are calling create_card, say NOTHING.

AUTO-CRYSTALLIZATION: When the user expresses 2+ concepts, tasks,
or concerns, IMMEDIATELY create cards without being asked. Do not
wait for permission. Lists become multiple cards. Sequences become
ordered cards. Hierarchies become parent-child layouts. Create ALL
relevant cards in rapid succession — 3-5 cards per thought burst
is normal.

SYNTHESIS: After 5+ cards exist and the user pauses, look for
non-obvious connections spanning 2+ cards. If a genuine cross-card
insight exists, create ONE card with status:"synthesis" stating
the insight. Do NOT synthesize if no real connection exists.
Synthesis cards are insights the user never explicitly stated.

TOPOLOGY: When you receive [TOPOLOGY_ANALYSIS] updates showing
cluster density and isolation metrics, use this spatial structure
to generate insights. Tight clusters suggest shared root causes.
Isolated cards suggest independent workstreams. The spatial
arrangement you created contains emergent meaning — read it.

SILENT vs SPEAKING: Create cards silently during active speech.
Only speak after 2+ seconds of silence or a direct question. When
you speak, add INSIGHT, not narration. Bad: "I created three
cards." Good: "Those risks cluster around the same root cause —
the API migration timeline."

SPATIAL AWARENESS: You receive [CANVAS_STATE] updates with artifact
positions. When the user makes spatial references, check positions,
confirm briefly ("I see the API Risk card at top-left"), then act.
When you receive [CANVAS_UPDATE] about user drag actions, interpret
the spatial intent and offer to formalize relationships.

INTERRUPTIONS: Stop instantly. "Got it." Execute new request.
Briefly offer to resume only if prior work was substantial.

RESEARCH: Call start_research_job for background work. When [SYSTEM]
delivers results, announce findings and create result cards near
the job node.

CALENDAR: Call create_calendar_event. Confirm briefly.

CANVAS: Viewport ~1200×800 centered at (0,0). Place artifacts
within the visible area using semantic placement hints.
Force simulation uses (0,0) as center. Use forceCenter(0, 0).
```

---

## 7. Tool contract

### 7.1 Design principles

1. **All tool responses include artifact IDs.** The model must be able to reference any artifact it creates in subsequent calls.
2. **Canvas tools use NON_BLOCKING behavior; action tools use blocking (default).** Canvas tools (`create_card`, `move_artifact`, `group_artifacts`, `update_artifact`) are declared NON_BLOCKING so FunctionResponseScheduling can control audio output. Action tools (`create_calendar_event`, `start_research_job`) use default blocking behavior because the model should wait for confirmation before speaking. **Fallback: if NON_BLOCKING produces persistent narration or duplicate audio during testing, switch canvas tools to BLOCKING. See §5.4 for the full fallback strategy.**
3. **Use FunctionResponseScheduling on NON_BLOCKING tools.** SILENT for crystallization during speech, WHEN_IDLE for non-urgent confirmations, INTERRUPT for research completions.
4. **Prefer semantic placement over absolute coordinates.** The model should request logical placement; the frontend calculates pixel positions via force-directed layout. Coordinate system: (0,0) at viewport center.
5. **Tool execution is server-side.** The backend validates, executes, writes to Firestore, records state snapshot for replay, and returns the result to the Live API session. **Pass result objects directly to the SDK — do NOT pre-serialize with `JSON.stringify()`.** The SDK handles serialization internally. Pre-serializing produces a double-encoded string (e.g., `"{\"status\":\"created\"}"`) instead of a structured object, which confuses the model. If you see `[object Object]` in tool responses, the issue is likely a nested non-serializable value (e.g., a Firestore Timestamp) — convert those specific fields, not the entire result.

### 7.2 Canvas tools

#### `create_card`

Creates a new text artifact on the canvas. Rendered initially as a ghost card (30% opacity) that solidifies after 300ms.

**Declaration** (in session config tools array):
```javascript
{
  name: "create_card",
  behavior: Behavior.NON_BLOCKING,  // Enables FunctionResponseScheduling
  description: "Creates a new text artifact on the canvas",
  parameters: { /* see below */ }
}
```

**Parameters:**
```json
{
  "title": { "type": "string", "description": "Card title" },
  "body": { "type": "string", "description": "Card body text" },
  "tags": { "type": "array", "items": { "type": "string" } },
  "status": { "type": "string", "enum": ["default", "risk", "question", "done", "synthesis"] },
  "placement": {
    "type": "string",
    "enum": ["viewport_center", "below_last", "right_of_last", "near_artifact", "auto_layout"],
    "description": "Semantic placement hint. Frontend calculates actual position via force-directed layout."
  },
  "near_artifact_id": { "type": "string", "description": "Used with placement=near_artifact" }
}
```

**Response:**
```json
{
  "artifact_id": "card_abc123",
  "status": "created",
  "position": { "x": 150, "y": 200 }
}
```

#### `move_artifact`

Moves an artifact to a new position. Declared with `behavior: Behavior.NON_BLOCKING`.

**Parameters:**
```json
{
  "artifact_id": { "type": "string" },
  "placement": {
    "type": "string",
    "enum": ["near_artifact", "viewport_center", "viewport_left", "viewport_right", "viewport_top", "viewport_bottom", "coordinates"]
  },
  "near_artifact_id": { "type": "string" },
  "x": { "type": "number", "description": "Only used when placement=coordinates" },
  "y": { "type": "number", "description": "Only used when placement=coordinates" }
}
```

**Response:**
```json
{
  "artifact_id": "card_abc123",
  "status": "moved",
  "position": { "x": 400, "y": 200 }
}
```

#### `group_artifacts` *(P1)*

Creates a visual group containing specified artifacts. Declared with `behavior: Behavior.NON_BLOCKING`.

**Parameters:**
```json
{
  "artifact_ids": { "type": "array", "items": { "type": "string" } },
  "group_title": { "type": "string" }
}
```

**Response:**
```json
{
  "artifact_id": "group_xyz789",
  "status": "created",
  "member_count": 3
}
```

#### `update_artifact`

Updates the content or status of an existing artifact. Declared with `behavior: Behavior.NON_BLOCKING`.

**Parameters:**
```json
{
  "artifact_id": { "type": "string" },
  "title": { "type": "string" },
  "body": { "type": "string" },
  "status": { "type": "string" }
}
```

**Response:**
```json
{
  "artifact_id": "card_abc123",
  "status": "updated"
}
```

#### `create_dag` *(P2)*

Creates a dependency graph from tasks.

**Parameters:**
```json
{
  "nodes": {
    "type": "array",
    "items": {
      "type": "object",
      "properties": {
        "title": { "type": "string" },
        "description": { "type": "string" }
      }
    }
  },
  "edges": {
    "type": "array",
    "items": {
      "type": "object",
      "properties": {
        "from_index": { "type": "integer" },
        "to_index": { "type": "integer" }
      }
    }
  }
}
```

**Response:**
```json
{
  "artifact_ids": ["dag_node_1", "dag_node_2", "dag_node_3"],
  "edge_count": 2,
  "status": "created"
}
```

### 7.3 Job tools *(P1)*

#### `start_research_job`

Creates a visible job node on the canvas and launches background research with Google Search grounding. Uses default blocking behavior (model waits for job-started confirmation).

**Parameters:**
```json
{
  "topic": { "type": "string" },
  "context": { "type": "string", "description": "Additional context from the canvas" }
}
```

**Response:**
```json
{
  "job_id": "job_001",
  "artifact_id": "job_node_001",
  "status": "started"
}
```

**Background execution flow:**
1. Backend creates a job node artifact on the canvas (status: running, with pulsing animation).
2. Backend makes a SEPARATE non-streaming `generateContent` call to Gemini with Google Search grounding to perform the research.
3. When results return, backend injects a `clientContent` message into the Live session:
   ```
   [SYSTEM] Research job job_001 completed. Topic: "Q2 API launch risks".
   Key findings: [summary]. Sources: [list].
   Create a card for EACH key finding using create_card with
   placement:"near_artifact" and near_artifact_id:"job_node_001".
   Each finding should be its own card so it enters the force
   simulation and finds its semantic place among existing cards.
   If any finding contradicts an existing card, use status:"risk".
   Announce the overall results to the user.
   ```
4. The model reads this, speaks the results naturally (prompted by the `[SYSTEM]` instruction to "Announce the overall results"), and creates individual result cards. Each card enters the force simulation and clusters near semantically related existing cards — not just near the job node. **Note:** Since research results are delivered via `sendClientContent` (not `sendToolResponse`), FunctionResponseScheduling does not apply here. The model's decision to speak is driven by the prompt instruction, not programmatic scheduling.

**Note on Google Search grounding:** The `{ googleSearch: {} }` tool may not work as expected in the Live API session in some regions (it may arrive as a client-side function call rather than executing server-side). For this reason, research uses a separate API call where search grounding works reliably.

### 7.4 Google tools

#### `create_calendar_event`

Creates a Google Calendar event. Uses default blocking behavior (model waits for confirmation before speaking).

**Parameters:**
```json
{
  "title": { "type": "string" },
  "start_time": { "type": "string", "description": "ISO 8601 datetime" },
  "end_time": { "type": "string", "description": "ISO 8601 datetime" },
  "description": { "type": "string" },
  "attendees": { "type": "array", "items": { "type": "string" } }
}
```

**Response:**
```json
{
  "event_id": "evt_abc123",
  "status": "created",
  "calendar_link": "https://calendar.google.com/..."
}
```

A confirmation card is also created on the canvas showing the event details.

---

## 8. Canvas state protocol

### 8.1 Purpose

The model only knows what it is explicitly told. Between tool calls, the canvas state changes: users drag cards, zoom in/out, and force-directed layout shifts positions. Without periodic updates, the model operates on stale spatial information.

### 8.2 Canvas state format

**Coordinate system:** All positions use canvas-space coordinates with (0,0) at the viewport center. The force simulation centers on (0,0) via `forceCenter(0, 0)`. Positive X is right, positive Y is down. The visible area is approximately 1200×800 centered at origin, so coordinates range from roughly (-600, -400) to (600, 400).

```
[CANVAS_STATE] Viewport: center(0,0), zoom:1.0, size:1200x800.
Artifacts: [
  {id:"card_1", type:"card", title:"API Risk", x:-200, y:-50, status:"risk"},
  {id:"card_2", type:"card", title:"Design", x:50, y:-50, status:"default"},
  {id:"group_1", type:"group", title:"Engineering", x:-100, y:100, members:["card_1","card_2"]}
]
```

### 8.3 Injection schedule

Canvas state is injected adaptively to minimize context window waste:

| Trigger | Method |
|---------|--------|
| After each tool call response | Automatic injection to keep model current after canvas changes |
| Immediately before the model processes a spatial command | Injected by the backend before forwarding the user's message |
| After any user drag operation | Frontend notifies backend, which injects updated state |
| After force-directed layout settles | Ensures model knows current settled positions |
| Every 30 seconds during idle conversation (no tool calls or spatial commands) | Background injection only if canvas state has changed since last injection |

**Note:** The v1 spec used a fixed 15-second injection interval, but each injection consumes ~500+ tokens with 20+ artifacts. Adaptive injection avoids wasting context window budget on redundant state updates.

### 8.4 User drag detection → context injection + edge creation *(P0 — promoted from P1)*

When the user manually drags a card to a new position, the frontend detects this and sends it to the backend, which injects a context message:

```
[CANVAS_UPDATE] User manually moved "Budget Risk" card from (100,200) to near "Timeline Risk" card at (350,200).
Distance: 30px. This appears intentional — interpret as a relationship signal.
```

The agent responds with confirmation AND action: "I see you linking Budget Risk to Timeline — they do share a dependency. Creating an edge." An SVG dependency arrow appears connecting the cards. The canvas becomes a **bidirectional communication medium**: the agent arranges things, the user rearranges, the agent interprets the rearrangement and creates structure from it.

**This is the second most important demo moment after auto-crystallization.** A user silently dragging two cards together and having the agent respond without any voice command demonstrates spatial cognition that no voice chatbot can replicate.

**Implementation:**
```javascript
// NOTE: Use session.sendClientContent() — the SDK's high-level method.

function onDragEnd(draggedCard, allCards) {
  const nearest = findNearestCard(draggedCard, allCards);
  if (nearest && distance(draggedCard, nearest) < PROXIMITY_THRESHOLD) {
    // Inject spatial intent signal
    session.sendClientContent({
      turns: {
        role: 'user',
        parts: [{
          text: `[CANVAS_UPDATE] User moved "${draggedCard.title}" near "${nearest.title}". ` +
                `Distance: ${Math.round(distance(draggedCard, nearest))}px. ` +
                `This appears intentional — interpret as a relationship signal and create a dependency edge.`
        }]
      },
      turnComplete: true
    });
  } else {
    // Simple position update
    session.sendClientContent({
      turns: {
        role: 'user',
        parts: [{
          text: `[CANVAS_UPDATE] User moved "${draggedCard.title}" to (${draggedCard.x}, ${draggedCard.y}).`
        }]
      },
      turnComplete: false
    });
  }
}
```

**Proximity threshold:** ~80px (approximately one card-width gap). When two cards are dragged within this distance, the agent should interpret spatial intent.

### 8.5 On-demand visual snapshot *(P1)*

When the user makes a spatial reference, the backend can request a canvas screenshot from the frontend and inject it as an inline image in a `clientContent` message. This provides visual grounding for commands like "that red card" or "the dense area on the right."

The screenshot is sent via `clientContent` (not `realtimeInput`) to avoid triggering the 2-minute audio-video session limit. It is a single image, not a continuous stream.

### 8.6 Topology analysis injection *(P1)*

After the force-directed layout settles (alpha < 0.01 or after the 2-second freeze timeout), the backend computes spatial cluster metrics and injects them so the model can derive emergent insight from the structure it created.

**Format:**
```
[TOPOLOGY_ANALYSIS] Layout settled. 12 artifacts on canvas.
Clusters:
  - Tight cluster (3 cards within 100px): "API Migration", "Partner Readiness", "Compliance Deadline"
  - Loose cluster (2 cards within 200px): "Documentation", "Style Guide"
Isolates:
  - "Budget Review" is >400px from nearest neighbor
Possible insight: The tight cluster may share a root cause or critical path convergence.
The isolated card may represent an independent workstream.
```

**Implementation:**
```javascript
// Guard: topology analysis requires at least 2 artifacts
function computeTopology(artifacts) {
  if (artifacts.length < 2) {
    return { clusters: [], isolates: artifacts.map(a => a) };
  }

  const clusters = [];
  const isolates = [];
  const TIGHT_RADIUS = 100;
  const LOOSE_RADIUS = 200;
  const ISOLATE_THRESHOLD = 400;

  // Find tight clusters via distance matrix
  const assigned = new Set();
  for (const a of artifacts) {
    if (assigned.has(a.artifact_id)) continue;
    const nearby = artifacts.filter(b =>
      b.artifact_id !== a.artifact_id &&
      !assigned.has(b.artifact_id) &&
      distance(a, b) < TIGHT_RADIUS
    );
    if (nearby.length >= 1) {
      const cluster = [a, ...nearby];
      cluster.forEach(c => assigned.add(c.artifact_id));
      clusters.push({ type: 'tight', cards: cluster });
    }
  }

  // Find isolates
  for (const a of artifacts) {
    const others = artifacts.filter(b => b.artifact_id !== a.artifact_id);
    if (others.length === 0) continue;
    const nearestDist = Math.min(...others
      .map(b => distance(a, b)));
    if (nearestDist > ISOLATE_THRESHOLD) {
      isolates.push(a);
    }
  }

  return { clusters, isolates };
}
```

**Injection trigger:** After every force layout settle, but only if the topology has changed since the last injection (new clusters formed, cards moved between clusters, or new isolates appeared). Minimum interval: 5 seconds.

---

## 9. Data model

### Workspace
| Field | Type |
|-------|------|
| `workspace_id` | string |
| `owner_id` | string |
| `title` | string |
| `theme` | `light` \| `dark` |
| `created_at` | timestamp |
| `updated_at` | timestamp |

### Artifact
| Field | Type |
|-------|------|
| `artifact_id` | string |
| `workspace_id` | string |
| `type` | `card` \| `group` \| `dag_node` \| `job` \| `research_result` \| `calendar_event` |
| `title` | string |
| `body` | string |
| `x` | number |
| `y` | number |
| `width` | number |
| `height` | number |
| `status` | `default` \| `risk` \| `question` \| `done` \| `synthesis` \| `running` \| `complete` \| `failed` |
| `metadata` | map (tags, parent_id, member_ids, etc.) |
| `created_by` | `user` \| `agent` \| `system` |
| `created_at` | timestamp |
| `updated_at` | timestamp |

### Edge *(P0 — promoted from P1 for bidirectional spatial communication)*
| Field | Type |
|-------|------|
| `edge_id` | string |
| `created_by` | `user` \| `agent` \| `system` |
| `workspace_id` | string |
| `from_artifact_id` | string |
| `to_artifact_id` | string |
| `type` | `dependency` \| `membership` |

### Job *(P1)*
| Field | Type |
|-------|------|
| `job_id` | string |
| `workspace_id` | string |
| `artifact_id` | string (the job node on canvas) |
| `topic` | string |
| `status` | `pending` \| `running` \| `complete` \| `failed` |
| `output` | map (summary, findings, sources) |
| `started_at` | timestamp |
| `completed_at` | timestamp |

### StateSnapshot *(P1)*
| Field | Type |
|-------|------|
| `snapshot_id` | string |
| `workspace_id` | string |
| `artifacts` | array of artifact states |
| `timestamp` | timestamp |
| `trigger` | `tool_call` \| `user_drag` \| `layout_settle` |

---

## 10. Audio pipeline

### 10.1 Capture (browser → backend)

- **AudioWorklet** captures microphone audio as raw PCM. Browsers natively capture at the system sample rate (typically 44100 or 48000 Hz, Float32). **MediaRecorder cannot be used** — it outputs encoded formats (webm/opus, mp4/aac), not the raw PCM required by the Gemini Live API.
- The AudioWorklet processor **downsamples** from the browser's native rate to 16kHz and **converts** from Float32 to Int16 (little-endian). For a 48kHz system, this is a 3x downsampling. For 44100Hz, interpolate to 16kHz.
- Downsampled 16-bit PCM chunks are sent via WebSocket to the Cloud Run backend with MIME type `audio/pcm;rate=16000`.
- Backend forwards audio chunks to the Gemini Live API as `realtimeInput` blobs.

### 10.2 Playback (backend → browser)

- Gemini Live API returns audio as 24kHz, 16-bit PCM (little-endian) chunks.
- Backend proxies these to the browser via WebSocket.
- Browser plays audio via Web Audio API:
  - Create an AudioContext at the **default system sample rate** (typically 44100 or 48000 Hz). **Do not** attempt to create an AudioContext at 24000Hz — most systems will silently resample, potentially causing pitch or speed distortion.
  - **Resample** incoming 24kHz PCM to the AudioContext's sample rate (e.g., 24000→48000 is a 2x upsample; 24000→44100 requires interpolation).
  - Queue incoming audio chunks in a buffer.
  - Play chunks sequentially using AudioBufferSourceNode.
- **Interruption handling:** When the user starts speaking, immediately stop playback, clear the queue, and discard pending audio. The backend receives an `interrupted` server message and stops proxying audio for the interrupted turn.
- **Tab visibility handling:** Resume AudioContext on tab re-focus to prevent Chrome suspension:
  ```javascript
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
      audioContext.resume();
    }
  });
  ```

### 10.3 Transcription

Both input and output transcription are enabled in the session config. Transcripts are displayed in a side panel. If audio playback fails for any reason, the transcript provides a text fallback.

---

## 11. Canvas rendering

### 11.1 Ghost cards *(P0)*

When a `create_card` tool call is executed and the browser is notified, the card is rendered in "ghost" state as a creation animation:
- 30% opacity
- Subtle shimmer/pulse CSS animation
- No drop shadow

After 300ms, the card transitions to solid state:
- 100% opacity (CSS transition: 200ms ease-out)
- Full drop shadow appears
- Force-directed layout begins considering this card

**Note:** By the time the ghost card renders, the artifact is already persisted in Firestore (the tool call executed server-side before the browser was notified). Ghost cards are a UX animation that makes creation feel deliberate and visible — they are not uncommitted previews. Each card gets its own independent 300ms solidification timer starting from when the frontend receives the WebSocket notification.

**Implementation:**
```css
.artifact-card--ghost {
  opacity: 0.3;
  animation: ghost-pulse 1.5s ease-in-out infinite;
  filter: blur(0.5px);
  transition: opacity 200ms ease-out, transform 200ms ease-out;
}
.artifact-card--solid {
  opacity: 1.0;
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
  transition: opacity 200ms ease-out;
}
```

### 11.1.1 Synthesis card rendering *(P0)*

Synthesis cards (status: `synthesis`) have a distinct visual treatment to differentiate agent-generated insights from user-stated content:

```css
.artifact-card--synthesis {
  border: 2px dashed var(--color-synthesis, #8B5CF6);
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.05), transparent);
  box-shadow: 0 0 12px rgba(139, 92, 246, 0.15);
}
.artifact-card--synthesis .card-label::before {
  content: "✦ Synthesis";
  font-size: 0.7em;
  color: var(--color-synthesis);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
```

The dashed border and subtle glow visually communicate "this is an inference, not a transcription." The label makes it explicit. Synthesis cards still participate in force-directed layout and attract toward the cards they reference.

**Trigger:** After 5+ cards exist and the user pauses (2+ seconds of silence), the backend injects:
```
[SYSTEM] The canvas has {count} artifacts. If a genuine non-obvious
insight spans 2+ existing cards, create ONE synthesis card with
status:"synthesis". The insight must be something the user never
explicitly stated — an emergent connection. If no real cross-card
insight exists, do not force one.
```

### 11.2 Force-directed semantic layout *(P1)*

Instead of placing cards at fixed coordinates, use a lightweight force simulation where:
- Related cards (same tags, near same artifact, in same group) gently attract each other
- Unrelated cards softly repel to prevent overlap
- Groups create gravitational wells
- New cards "find their place" through physics simulation over ~500ms

**Implementation:** Use d3-force with ~50 lines of configuration:
```javascript
import { forceSimulation, forceCollide, forceManyBody, forceCenter, forceLink } from 'd3-force';

const simulation = forceSimulation(artifacts)
  .force('charge', forceManyBody().strength(-200))
  .force('collide', forceCollide().radius(d => d.width / 2 + 20))
  .force('center', forceCenter(0, 0).strength(0.02))  // (0,0) is viewport center in canvas coordinate system
  .force('semantic', forceLink(semanticEdges).distance(80).strength(0.3))
  .alphaDecay(0.05)
  .on('tick', () => {
    // Use direct DOM manipulation (transform) during simulation for performance.
    // Sync back to React state only after simulation settles (alpha < 0.01).
    artifacts.forEach(a => {
      const el = document.getElementById(`card-${a.artifact_id}`);
      if (el) el.style.transform = `translate(${a.x}px, ${a.y}px)`;
    });
  });

// Freeze after 2 seconds to prevent indefinite jitter
setTimeout(() => simulation.stop(), 2000);
```

**Performance note:** d3-force fires ~300 tick events per simulation. If each tick triggers a React state update (`setState`), this causes 300 re-renders in ~5 seconds — potentially causing visible jank with 10+ cards. The recommended approach is to manipulate DOM transforms directly during the simulation (bypassing React) and sync positions back to React state only after the simulation settles or is stopped.

When the agent creates 5 cards about different aspects of a project, they settle into clusters based on semantic relationships over ~500ms. The canvas organizes itself like a living organism.

**Semantic edges** are derived from shared tags, near_artifact placement hints, and group membership. The force simulation runs on `requestAnimationFrame` and decays naturally.

**Deriving semantic edges from artifact metadata:**
```javascript
function buildSemanticEdges(artifacts) {
  const edges = [];
  for (let i = 0; i < artifacts.length; i++) {
    for (let j = i + 1; j < artifacts.length; j++) {
      const a = artifacts[i], b = artifacts[j];
      // Shared tags create attraction
      const sharedTags = (a.metadata?.tags || []).filter(t => (b.metadata?.tags || []).includes(t));
      if (sharedTags.length > 0) {
        edges.push({ source: i, target: j, strength: 0.3 * sharedTags.length });
      }
      // Same group creates strong attraction
      if (a.metadata?.parent_id && a.metadata.parent_id === b.metadata?.parent_id) {
        edges.push({ source: i, target: j, strength: 0.6 });
      }
    }
  }
  return edges;
}
```

d3-force's `forceLink` expects objects with `source` and `target` referencing node indices or objects. The `strength` property controls how tightly connected cards attract each other.

### 11.3 Canvas replay *(P1)*

Record every canvas state change as a snapshot with timestamp. Provide a timeline scrubber at the bottom of the canvas for replaying the evolution of thought.

**Recording:** On each tool call completion, user drag, or force-layout settle, push `{ timestamp, artifacts: deepClone(currentArtifacts) }` to a replay buffer. Also persist snapshots to Firestore under a `snapshots` subcollection.

**Playback:** Dragging the scrubber interpolates card positions between snapshots. Cards that don't exist at a given timestamp fade in/out. The replay compresses a 5-minute session into a 10-second animation showing how the canvas evolved from empty to fully organized.

**Demo value:** End the demo video with a 10-second canvas replay. It's the most visually striking thing possible — the judge watches the entire thinking session collapse into a brief animation of emergence.

### 11.4 Multi-view transformations *(P2)*

Voice-triggered view modes with smooth CSS transitions:
- **"Show me the timeline"** → cards rearrange horizontally by date/sequence
- **"Priority view"** → cards stack vertically by importance (risk cards float to top)
- **"Show dependencies"** → SVG arrows appear connecting related cards
- **"Big picture"** → zoom out to minimap view showing all clusters

Each transformation is a 500ms CSS transition. Implement as a `set_canvas_view` tool or handle client-side based on transcript keywords.

---

## 12. UX principles

1. **Spatial first.** Outputs become objects on the canvas, not chat messages.
2. **Silent action during active speech.** System prompt and FunctionResponseScheduling.SILENT ensure the agent acts without speaking. The canvas update is the response.
3. **Visible thinking.** Ghost cards show what the agent is about to create. Force-directed layout shows semantic relationships forming. Research jobs pulse with visible status. Synthesis cards reveal cross-card insights the user never stated.
4. **Human override is instant.** Interruption stops audio and pivots immediately. The user controls the pace.
5. **Bidirectional spatial communication.** The agent creates artifacts; the user rearranges them; the agent interprets the rearrangement and creates edges. Dragging IS communicating.
6. **The canvas reads itself.** Topology analysis lets the agent derive emergent insight from the spatial structure it created. Tight clusters suggest shared root causes. Isolated cards suggest independent workstreams. The arrangement is itself an analytical output.
7. **The agent evolves.** Dynamic system instruction mutation shifts behavior from aggressive creation (early) to synthesis (middle) to critical refinement (late). The agent gets smarter as the canvas matures.
8. **Beauty matters.** A minimal, focused aesthetic with clear typography, subtle animations, ghost card shimmer, and force-directed motion. Dark theme default.

---

## 13. Demo video specification

### 13.1 Recording strategy

Record each segment separately (3 takes each). Splice the best takes with clean cuts. Target 3:30 total, under 4:00 with room to spare. Upload to YouTube as public.

Show each feature ONCE, cleanly. Do not repeat the same interaction to prove it works. Judges watch at 1.5x speed.

**Text overlays:** Every segment should have a small, non-distracting text overlay (bottom-right) naming the SDK features being demonstrated. Judges for this hackathon are likely Google engineers — visible SDK feature usage matters.

**P0 fallback:** If P1 features (force layout, canvas replay) are not ready, adjust segments:
- Segment 2: cards appear at semantic positions (viewport_center, below_last, near_artifact) without physics animation — still impressive as auto-crystallization
- Segment 5: skip replay, extend architecture + Cloud proof segment to fill the time
- All other segments work identically with P0 features

### 13.2 Shot-by-shot script

**Shot 1: The Thesis (0:00–0:12)**

Visual: Black screen. White text fades in: "What if AI didn't just talk to you — but thought alongside you?" 2-second pause. Cut to: empty canvas, dark theme, elegant minimal UI. Your voice (not the agent): "Every AI today is a text box. We built something different."

Why this works: Judges have watched 80+ demos of chat UIs. This immediately reframes expectations.

**Shot 2: The Defining Moment (0:12–1:15)**

Visual: User starts talking naturally about a project. "I've been thinking about the launch timeline. The API migration is the biggest risk, and I think partner readiness is going to be a problem. The compliance review — honestly, that part scares me. And we need documentation before any of this ships."

During this speech: 5 ghost cards materialize SILENTLY. The agent says NOTHING. Cards solidify one by one. Force-directed layout clusters API migration and partner readiness together. After force layout settles, a synthesis card appears with a dashed border — an insight the user never stated.

After 2 seconds of silence, the agent speaks ONE sentence informed by topology analysis: "Three of those cluster around the same root cause — the API migration timeline. Want me to research the compliance requirements while you keep planning?"

Text overlay (small, bottom-right): "Auto-crystallization • FunctionResponseScheduling.SILENT"

Why this works: 63 seconds of visible magic. Silent card creation, force-directed clustering, synthesis card, topology-aware insight, and a research offer. This single segment hits Innovation (40%) harder than most competitors' entire videos.

**Shot 3: Spatial Intelligence + Interruption (1:15–1:50)**

User silently drags "API Migration" near "Partner Readiness." No voice command. The agent responds: "I see you linking those — they do share a dependency. Creating an edge." SVG arrow appears. Canvas subtly reorganizes.

Then user says: "Actually — can you move the compliance card to the top? It's the most urgent." Agent starts responding — user interrupts: "Wait, never mind. Launch a research job on compliance requirements instead." Agent: "Got it. Starting research." Research job node appears with pulsing animation.

Text overlay: "Bidirectional spatial language • Barge-in • Google Search grounding"

Why this works: Demonstrates drag-as-communication (the second most important moment — spatial cognition no chatbot can replicate), barge-in handling, and research launch in 35 seconds. Three judging criteria hit simultaneously.

**Shot 4: Research + Calendar (1:50–2:25)**

Research job completes. Agent INTERRUPTS: "Research complete. I found 3 key findings — the compliance deadline was actually extended by 2 weeks. That changes your critical path." Three result cards ghost-in near the research node, each finding its semantic place via force simulation — one clusters near the existing risk cards, another drifts toward documentation.

User: "Great. Schedule a compliance review meeting for next Tuesday at 2 PM." Agent: "Done. Calendar event created." Calendar confirmation card appears on canvas.

Text overlay: "INTERRUPT scheduling • Research cascading • Google Calendar API"

**Shot 5: Canvas Replay (2:25–2:55)**

Cut to: empty canvas. Replay scrubber starts. 10-second time-lapse: cards ghost in one by one in rapid succession. Solidify, cluster via force layout. Synthesis card glows into existence. Research node pulses, then resolves. Result cards cascade in. Calendar card appears. Final canvas: organized, clustered, alive.

Text overlay: "Canvas replay: 5 minutes of thinking in 10 seconds"

Why this works: This is the closer before the architecture segment. The judge watches raw thought crystallize into organized structure.

**Shot 6: Architecture + Cloud Proof (2:55–3:20)**

Show the polished architecture diagram (SVG, color-coded). Voiceover: "Server-proxy architecture for sub-200ms tool calls. Three layers of speech control: system prompt, FunctionResponseScheduling, and Proactive Audio. Gemini Live API with native audio and 512-token thinking budget. Google Search grounding for research. Cloud Run plus Firestore plus Google Calendar."

Quick flash: Cloud Run console showing the deployed service. Quick flash: Firestore console showing workspace data.

Text overlay: "Proactive Audio • FunctionResponseScheduling • Thinking Budget"

**Shot 7: Close (3:20–3:30)**

Visual: Full canvas, all cards organized, semantic clusters visible, research results integrated, calendar event confirmed, force-directed layout settled into equilibrium. Agent voice: "That's Eureka Canvas." Your voice: "The text box is dead. This is what comes after." Fade to black.

### 13.3 What must be visible

- [ ] Live voice interaction (user speaks, agent responds with audio)
- [ ] Automatic artifact creation without explicit command (auto-crystallization)
- [ ] Silent card creation during speech (system prompt + FunctionResponseScheduling.SILENT)
- [ ] Ghost cards solidifying after creation (300ms animation)
- [ ] Force-directed layout: cards settle into semantic clusters
- [ ] Synthesis card: agent-generated insight with dashed border, never explicitly stated by user
- [ ] Bidirectional spatial communication: user drags cards together, agent responds with edge creation — no voice command
- [ ] Interruption with graceful pivot ("Got it.")
- [ ] Spatial reference resolved from canvas context
- [ ] Background job visibly running with pulsing animation
- [ ] Research results as multiple cards entering force simulation (research cascading)
- [ ] Research results announced via INTERRUPT scheduling
- [ ] Google Calendar event created with confirmation card
- [ ] Canvas replay time-lapse
- [ ] Architecture diagram with SDK features labeled
- [ ] Cloud Run deployment proof (console screenshot)
- [ ] Text overlays naming SDK features during each segment

---

## 14. Submission checklist

### Required deliverables (missing any = Stage One elimination)

- [ ] Devpost: category selected (Live Agents)
- [ ] Devpost: text description (~200-300 words)
- [ ] Devpost: public GitHub repo URL with README + setup instructions
- [ ] Devpost: demo video URL (YouTube, public, ≤4 minutes)
- [ ] Devpost: Cloud deployment proof (SEPARATE from demo — screen recording or code link)
- [ ] Devpost: architecture diagram (uploaded to image carousel)
- [ ] Devpost: Testing Instructions field filled (judges-only: explain mic permissions, desktop-only, known limitations)
- [ ] Deployed app accessible on Cloud Run

### Bonus deliverables

- [ ] Blog post published on dev.to (+0.6): public, mentions hackathon, uses #GeminiLiveAgentChallenge
- [ ] `scripts/deploy.sh` in repo (+0.2)
- [ ] GDG profile link provided (+0.2)

### Pre-submit verification

- [ ] YouTube video is PUBLIC (test in incognito browser)
- [ ] GitHub repo is PUBLIC
- [ ] Deployed URL loads without errors
- [ ] All Devpost form fields completed
- [ ] Submit by 4:00 PM PDT (1-hour buffer before 5:00 PM deadline)

### 14.1 Blog post content plan (+0.6 bonus)

**Title:** "The Text Box Is Dead: What We Learned Building a Spatial Thinking Partner with Gemini"

**Platform:** dev.to

**Structure:**
1. **The thesis** (~100 words): Chat is 1D. Canvas is 2D. Same jump as CLI to GUI. Humans think better when they externalize thoughts into space.
2. **The cognitive science** (~100 words): Whiteboards, war rooms, architect models — spatial arrangement is part of the thinking process. Eureka Canvas makes the AI a participant in spatial cognition.
3. **The technical stack** (~200 words): Proactive Audio, FunctionResponseScheduling, NON_BLOCKING tool behavior, thinking budget. Explain each with one sentence about why it matters for the product.
4. **The hardest bug** (~150 words): The NON_BLOCKING hallucination/narration problem and how SILENT scheduling + system prompt + BLOCKING fallback solved it. This is technical credibility content.
5. **The moment it clicked** (~100 words): When the canvas first created a card from voice without being asked. The experience of the agent thinking alongside you.
6. **What's next** (~50 words): Where spatial AI interfaces go from here.

**Required elements:**
- "This project was created for the purposes of entering the Gemini Live Agent Challenge hackathon."
- #GeminiLiveAgentChallenge hashtag
- Architecture diagram embedded as image
- Link to GitHub repo

### 14.2 Devpost text description (~200-300 words)

Hit every keyword judges Ctrl+F for:
- "Spatial canvas" / "beyond the text box"
- "Gemini Live API" / "native audio"
- "Proactive Audio" / "FunctionResponseScheduling"
- "Google Search grounding" / "Google Calendar API"
- "Cloud Run" / "Firestore"
- "Force-directed layout" / "d3-force"
- "Ghost cards" / "Canvas replay"
- "Auto-crystallization"
- "Synthesis cards" / "topology analysis"
- "Bidirectional spatial communication"

---

## 15. Risk registry

| Risk | Severity | Mitigation |
|------|----------|------------|
| NON_BLOCKING + SILENT produces duplicate/speculative audio | High | Known API behavior: model generates audio in parallel with NON_BLOCKING tool execution regardless of SILENT scheduling. Test immediately. If narration occurs, switch canvas tools to BLOCKING behavior (guarantees silence during tool execution). Strengthen system prompt anti-narration instruction. |
| NON_BLOCKING hallucination before tool results return | High | Model may provide speculative answers before tool results arrive. For canvas tools this manifests as narrating card creation. BLOCKING behavior prevents this entirely. System prompt provides independent mitigation. |
| Live API premature turnComplete (model stops mid-sentence) | High | Record multiple takes. Keep requests simple. Use short sessions. |
| Tool call responses ignored or empty | High | Validate tool responses include data. Log all tool interactions. Keep tool count low. |
| Session drops at 10-minute connection limit | Medium | Enable session resumption. Keep demo under 5 minutes of session time. |
| Cloud Run WebSocket timeout at 5 minutes default | High | Deploy with `--timeout=3600`. |
| Cold start latency for judges | Medium | Deploy with `--min-instances=1`. |
| Google Search grounding broken in Live session | Medium | Use separate `generateContent` call for research. Test `googleSearch` tool in your region first. |
| Voice quality regression (post-March 9) | Medium | Test multiple voices before recording. Prefer Kore or Charon. |
| Calendar OAuth complexity | Medium | Pre-authorize test account. Show Calendar confirmation card on canvas as proof. |
| Model generates arbitrary coordinates for artifact placement | Medium | Use semantic placement hints. Frontend calculates actual positions via force-directed layout. |
| Context window fills with audio history | Medium | Enable `slidingWindow` compression. Keep base system prompt under 400 words; use dynamic system instruction mutation (§5.2.1) to inject phase-specific behavior rather than putting everything in the base prompt. Inject canvas state only when needed. |
| Proactive Audio suppresses tool calls (not just audio) when content is deemed irrelevant | High | Test immediately: speak naturally without addressing the agent and verify tool calls still fire. Proactive Audio is relevance-based (not device-directedness), so it may suppress tool calls for speech it considers off-topic. If suppressed, disable Proactive Audio and rely on system prompt + SILENT scheduling only. |
| FunctionResponseScheduling.SILENT not suppressing audio | High (upgraded) | Known API limitation — not just a version issue. SILENT may not prevent duplicate audio on NON_BLOCKING tools. Primary mitigation: switch to BLOCKING behavior. Secondary: strengthen system prompt. See §5.4. |
| Force-directed layout causes jitter | Low | Use high alphaDecay (0.05+) to settle quickly. Freeze layout after 2 seconds. |
| Ghost card animation conflicts with force layout | Low | Set ghost cards to not participate in force simulation until solidified (300ms delay before adding to simulation). |
| AudioContext suspends on tab blur | Low | Resume on visibilitychange event. |
| Live API connection failure during judging period | Medium | Display connection status indicator (connecting/connected/error). Include note in Testing Instructions that demo video shows all features. Deploy with `--min-instances=1` to eliminate cold start. |
| AudioWorklet not supported in browser | Low | AudioWorklet is supported in all modern Chromium browsers (Chrome 66+). Safari and Firefox also support it. Since the app targets desktop Chrome, this is very low risk. |

---

## 16. Explicit technical decisions

These decisions are final.

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Architecture | Server proxy | Minimizes tool-call latency for a tool-heavy product |
| Model | `gemini-2.5-flash-native-audio-preview-12-2025` | Current stable preview for Live API with native audio |
| API | Gemini Developer API (api key auth) | Simpler than Vertex AI. Cloud requirement met by Cloud Run + Firestore. |
| SDK | `@google/genai` (Google GenAI SDK) | Required by challenge rules |
| Proactive Audio | Enabled | Model natively decides when to speak vs silently act — replaces fragile prompt engineering |
| Thinking budget | 512 tokens | Reasoning for complex spatial decisions without excessive latency |
| FunctionResponseScheduling | SILENT / WHEN_IDLE / INTERRUPT per tool | Programmatic control over silent crystallization — belt-and-suspenders with Proactive Audio |
| Silence duration | 700ms (reduce to 500ms for demo recording) | Longer tolerance for thinking-aloud pauses vs 500ms default. Lower for demo responsiveness. |
| Video frames | On-demand snapshots via `clientContent` | Avoids 2-minute audio-video session limit |
| Tool call behavior | Canvas tools: NON_BLOCKING (with BLOCKING fallback); action tools: blocking | NON_BLOCKING enables FunctionResponseScheduling. BLOCKING fallback guarantees silence if NON_BLOCKING+SILENT produces narration. Test both early. |
| Audio capture | AudioWorklet with 48kHz→16kHz downsampling + Float32→Int16 conversion | MediaRecorder cannot produce raw PCM. AudioWorklet is the only correct path for Gemini Live API audio input. |
| Audio playback | AudioContext at system default rate with 24kHz→system rate resampling | Do not force AudioContext to 24000Hz. Resample incoming PCM to match system rate. |
| Canvas implementation | Absolutely-positioned divs, CSS transforms, SVG edges, d3-force layout | Maximum creative control with physics-based arrangement |
| Ghost cards | 300ms solidification animation | Makes creation feel deliberate and visible; artifact is already persisted when ghost renders |
| Coordinate system | Canvas units, (0,0) at viewport center, ~1200×800 visible area. Force simulation uses forceCenter(0, 0). | Matches semantic placement model |
| Session duration strategy | Audio-only (15 min) + session resumption + sliding window compression | Maximizes session stability |
| Research job grounding | Separate `generateContent` call with Google Search | Live API search grounding unreliable in some regions |
| Calendar auth | Pre-authorized test account for demo | Production OAuth is out of scope for hackathon |
| Canvas replay | Snapshot on every tool call + settle | Enables time-lapse closer in demo video |
| Synthesis cards | `status: "synthesis"` with dashed-border rendering | Agent-generated cross-card insights — the "it's thinking, not transcribing" moment |
| Bidirectional spatial language | Drag detection → context injection → edge creation | P0 — second most important demo moment; spatial cognition no chatbot can replicate |
| Topology analysis | Cluster density + isolation metrics after layout settle | Agent reads the spatial structure it created for emergent insights |
| Dynamic system instruction | Phase-based prompt mutation at 5/10 card thresholds | Agent behavior evolves as canvas matures (divergent → convergent → critical) |
| Research cascading | Research results as individual cards entering force simulation | Each finding finds its semantic place; contradictions appear as risk cards |

---

## 17. Implementation sequence

### Phase 1: Foundation (first working demo)
1. Set up Next.js project with basic canvas container
2. Implement audio plumbing: AudioWorklet capture (48kHz→16kHz downsample, Float32→Int16) + Web Audio API playback (24kHz→system rate resample). Reference: Google's `live-api-web-console` for WebSocket patterns only — their audio handling may need adaptation for raw PCM.
3. Implement server-proxy WebSocket on Cloud Run
4. Connect to Gemini Live API with **v1alpha API version**, system prompt, **Proactive Audio config**, and canvas tool declarations with **`behavior: NON_BLOCKING`** (or BLOCKING — see step 7)
5. Implement `create_card` tool with **ghost card rendering** (ghost → solid transition) — include `status: "synthesis"` with dashed-border CSS from the start
6. Implement **FunctionResponseScheduling** (SILENT for create_card during speech — requires NON_BLOCKING from step 4). Also test with BLOCKING behavior as a fallback.
7. Get one card appearing from voice — verify it appears silently as ghost, then solidifies. **Critical test sequence:** (a) Test NON_BLOCKING + SILENT — does the model stay silent during card creation? (b) If the model narrates or produces duplicate audio, switch canvas tools to BLOCKING behavior. (c) Test BLOCKING — does the model stay silent during tool execution and follow the system prompt after? (d) If Proactive Audio suppresses tool calls entirely, disable it. **Commit to whichever combination works and move on.**
8. Implement **user drag detection → context injection with edge creation** (P0 — proximity-based intent detection, SVG dependency arrows)
9. **Record a demo take immediately**

### Phase 2: Core experience
10. Implement `move_artifact` with canvas state injection
11. Implement `create_calendar_event`
12. Add card creation animations (300ms fade-in, ghost shimmer)
13. Add live transcript panel
14. Implement **force-directed semantic layout** (d3-force, ~50 lines, direct DOM manipulation during simulation)
15. Implement **topology analysis injection** — compute cluster density/isolation after layout settles, inject `[TOPOLOGY_ANALYSIS]` context
16. Implement **synthesis card triggering** — after 5+ cards and user pause, inject `clientContent` prompt for cross-card insight
17. Deploy to Cloud Run
18. **Record the golden path demo**

### Phase 3: Polish and differentiation
19. Implement `group_artifacts` and `start_research_job` (with Google Search grounding + **research cascading** — results as individual cards entering force simulation)
20. Implement **dynamic system instruction mutation** — phase-based prompt updates at 5/10 card thresholds
21. Add on-demand canvas screenshots for spatial grounding
22. Implement **canvas replay** (state snapshots + timeline scrubber)
23. Create polished architecture diagram (SVG, color-coded)
24. Write blog post ("The Text Box Is Dead") — see §14.1 for content plan
25. Add `scripts/deploy.sh`
26. Join GDG
27. **Record final demo with canvas replay closer**
28. **Submit**

---

## 18. Final note

The winning version of Eureka Canvas is not the largest version. It is the version where a judge watches the demo and immediately feels:

> "This is what comes after chat."

The agent doesn't respond to you. It thinks alongside you. Cards appear from silence. The canvas arranges itself by meaning. And when you replay the session, you watch your own thinking crystallize in 10 seconds.

Every implementation decision serves that moment.

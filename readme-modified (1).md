# Eureka Canvas

**A live, screen-aware workspace where Gemini turns conversation into spatial thinking, background work, and real action.**

Eureka Canvas is a multimodal web app built for the **Gemini Live Agent Challenge**. It gives Gemini a persistent visual canvas that it can understand and manipulate in real time. Users speak naturally, interrupt the agent, reference what is visible on screen, launch background research, and take real action through Google Calendar — all without leaving the workspace.

## Why this exists

Most AI products are linear chat interfaces. Context disappears up the thread, long-running work is invisible, and everything becomes a turn-by-turn bottleneck.

Eureka Canvas treats the workspace itself as shared context. The agent perceives the canvas, structures messy thoughts into spatial artifacts, and acts on what it sees. The result is a collaboration model where thoughts become objects, structure becomes visible, background work becomes trackable, and actions happen directly from the workspace.

The insight comes from cognitive science: humans think better when they externalize their thoughts into space. Whiteboards, war rooms, architect models — spatial arrangement isn't decoration, it's part of the thinking process. Eureka Canvas makes the AI a participant in this spatial cognition. Chat is 1-dimensional (time-ordered). Canvas is 2-dimensional (spatial relationships). This is the same jump from the command line to the graphical UI.

## Core concept

A user says:

> "Help me plan this project. I'm worried about the API migration timeline, and the compliance deadline is making me nervous. We also need partner outreach and documentation."

Eureka Canvas detects structured thinking and creates spatial artifacts *silently* — the system prompt instructs the agent to never narrate tool calls, and **FunctionResponseScheduling** controls whether the model speaks after each tool response. Cards cluster semantically via **force-directed physics layout**. When the user pauses, the agent offers a single insight: "Those risks cluster around the same root cause — the API migration timeline. Want me to research the compliance requirements?"

No commands. No prompting. The canvas structures your thinking in real time.

## Key features

### Conversation crystallization
The agent automatically detects structured thinking in natural speech and creates spatial artifacts without being asked. Say three concerns out loud and three cards appear, arranged semantically. Cards first appear as translucent **ghost cards** that solidify after 300ms, making creation feel deliberate and visible.

### Proactive Audio — the agent knows when to think and when to talk
Powered by Gemini's native **Proactive Audio** capability, the model can proactively decide not to respond when it determines the input content is not relevant. This is a topic/relevance-based filter — for example, the model can be instructed to only respond when the conversation is about project planning. The system prompt reinforces this behavior, and **FunctionResponseScheduling** provides programmatic control over when the model generates audio after tool execution.

**Note:** Proactive Audio may suppress tool calls (not just audio) for speech it classifies as irrelevant. Silent crystallization is designed to work without Proactive Audio via the system prompt and FunctionResponseScheduling. If Proactive Audio interferes with tool calls, it can be disabled with one config change.

### FunctionResponseScheduling — silent, idle, or interrupt
The Gemini Live API supports **FunctionResponseScheduling** on `NON_BLOCKING` tools, enabling programmatic control over when the model generates audio after tool execution:
- **SILENT**: Cards appear without any audio (during active speech)
- **WHEN_IDLE**: Agent comments after the user pauses (for confirmations)
- **INTERRUPT**: Agent speaks immediately (for urgent results)

**Implementation note:** The initial build uses default BLOCKING tool behavior for canvas tools, which provides guaranteed silence during tool execution (the model cannot speak while a blocking tool runs). The system prompt reinforces silence after tool responses. If time permits, an upgrade path to NON_BLOCKING + SILENT is documented in the spec (§5.4) for finer-grained scheduling control. The README documents the full architecture including NON_BLOCKING capabilities to demonstrate SDK knowledge.

### Live voice interaction
Real-time bidirectional voice powered by the Gemini Live API with native audio. Interruptible responses for natural collaboration. Text input fallback with live transcription of both user and agent speech. 700ms silence tolerance for thinking-aloud patterns.

### Screen-aware spatial intelligence
The agent receives structured canvas state injected via `sendClientContent`. Spatial references like "move that cluster" or "turn those notes into a graph" are resolved from the current visible layout. When you manually drag a card near another card, the agent interprets it as a relationship signal and creates a dependency edge — no voice command needed. Dragging IS communicating.

### Force-directed semantic layout
Cards don't just appear at fixed coordinates — they settle into clusters based on semantic relationships using a **force-directed physics simulation**. Related cards attract each other, unrelated cards repel. Groups create gravitational wells. The canvas organizes itself like a living organism. When the agent creates 5 cards, they *find their place* through physics.

### Topology analysis — the canvas reads itself
After the force-directed layout settles, the system analyzes the spatial structure: which cards cluster tightly, which orbit loosely, which float alone. The agent uses this topology to generate emergent insights: "Three of your concerns cluster around the same root cause — the API migration timeline. But documentation is orbiting alone. That might be your one truly independent workstream." The spatial arrangement is itself an analytical output.

### Synthesis cards — insights the user never stated
After 5+ cards exist, the agent looks for non-obvious connections spanning multiple cards and creates a **synthesis card** with a dashed border and distinct visual treatment. These cards contain cross-card insights the user never explicitly stated — emergent connections derived from the canvas as a whole. The agent isn't just organizing your thoughts; it's thinking alongside you.

### Ghost cards — visible creation
New cards arrive as translucent ghost previews (30% opacity with a subtle shimmer). After 300ms, they solidify into full cards. This creation animation makes the agent's work feel deliberate and visible — you can see the canvas being built in real time rather than cards snapping into existence.

### Background research
Launch research tasks that run asynchronously with **Google Search grounding** while you keep working. The job status is visible on the canvas with a pulsing animation. Results are injected into the Live API session via `sendClientContent`, and the agent announces findings and creates individual result cards that enter the force simulation (research cascading).

### Google Calendar integration
Turn plans into action. Ask the agent to schedule a meeting, and it creates a Google Calendar event directly from the workspace. A confirmation card appears on the canvas.

### Canvas replay
Every canvas state change is recorded with a timestamp. A **timeline scrubber** lets you replay how the canvas evolved during the session — cards appearing as ghosts, solidifying, clustering, research completing. A 5-minute thinking session compresses into a 10-second animation of thought crystallization.

### Persistence
Workspace state is saved to Firestore. Refresh the page or return later and pick up where you left off.

## Tech stack

| Layer | Technology |
|-------|-----------|
| Frontend | Next.js, React |
| Canvas | HTML/CSS with absolute positioning, CSS transforms for pan/zoom, SVG edges, d3-force for semantic layout |
| Voice | Web Audio API with AudioWorklet (48kHz→16kHz downsampled capture, 24kHz→system rate resampled playback) |
| Backend | Node.js on Google Cloud Run |
| Model | Gemini 2.5 Flash Native Audio via Gemini Live API (bidirectional WebSocket) |
| Native features | Proactive Audio, thinking budget, FunctionResponseScheduling |
| Persistence | Google Cloud Firestore |
| Research | Gemini API with Google Search grounding (separate `generateContent` call) |
| External action | Google Calendar API |
| Deployment | Google Cloud Run |

**Model:** `gemini-2.5-flash-native-audio-preview-12-2025`
**SDK:** Google GenAI SDK (`@google/genai`)

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                      Browser                         │
│  ┌────────────┐  ┌───────────┐  ┌───────────────┐  │
│  │ Canvas UI  │  │ Audio I/O │  │  Transcript   │  │
│  │ • Ghost    │  │ • 16kHz ↑ │  │  Panel        │  │
│  │   cards    │  │ • 24kHz ↓ │  │               │  │
│  │ • d3-force │  │ • Barge-in│  │               │  │
│  │ • Replay   │  │           │  │               │  │
│  └─────┬──────┘  └─────┬─────┘  └───────────────┘  │
│        │               │                             │
└────────┼───────────────┼─────────────────────────────┘
         │   WebSocket   │
         ▼               ▼
┌─────────────────────────────────────────────────────┐
│              Cloud Run (Node.js)                     │
│                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │ Live API     │  │ Tool         │  │ Research  │ │
│  │ Session Mgr  │  │ Executor     │  │ Runner    │ │
│  │              │  │              │  │           │ │
│  │ • Proactive  │  │ • BLOCKING   │  │ • Google  │ │
│  │   Audio      │◄─┤   (default)  │  │   Search  │ │
│  │ • Thinking   │  │ • Validated  │  │   ground. │ │
│  │   budget     │  │              │  │           │ │
│  │ • Session    │  │ • Canvas     │  │ • Async   │ │
│  │   resumption │  │   state inj. │  │   inject  │ │
│  │              │  │ • Drag det.  │  │   results │ │
│  │              │  │ • Snapshot   │  │           │ │
│  └──────┬───────┘  └──────┬───────┘  └─────┬─────┘ │
│         │                 │                 │       │
└─────────┼─────────────────┼─────────────────┼───────┘
          │                 │                 │
          ▼                 ▼                 ▼
    Gemini Live API    Firestore        Google Calendar
    (WebSocket)        • Workspace      + Gemini API
                       • Artifacts        (search grounding)
                       • Snapshots
```

**Architecture:** Server-proxy. The backend manages the Gemini Live API WebSocket session, executes tool calls server-side, and proxies audio between browser and API. This minimizes tool-call latency (critical when creating multiple artifacts per interaction: ~100-200ms server-side vs ~300-500ms client-direct) and keeps OAuth tokens server-side.

### Core design principles

1. **The canvas is the primary shared context.** The agent's understanding of the workspace is grounded in structured canvas state injected via `sendClientContent`.
2. **The model never mutates state directly.** It invokes validated tools. Every tool response includes artifact IDs for future reference.
3. **The model's speech is controlled by reinforcing mechanisms.** System prompt instructs silent crystallization and forbids narrating tool calls. Canvas tools default to BLOCKING behavior, which guarantees silence during tool execution. Proactive Audio (when enabled) adds model-level judgment about when to speak. The architecture supports upgrading to NON_BLOCKING + FunctionResponseScheduling for finer-grained control (see spec §5.4).
4. **The canvas reads itself.** After force-directed layout settles, topology analysis computes cluster density and isolation. The agent derives emergent insight from the spatial structure it created — tight clusters suggest shared root causes, isolated cards suggest independent workstreams.
5. **The agent thinks, not just transcribes.** Synthesis cards contain cross-card insights the user never explicitly stated. The agent creates structure from speech, then reads that structure for meaning that wasn't in any single card.
6. **The canvas communicates bidirectionally.** The agent creates artifacts; the user rearranges them; the agent interprets the rearrangement and creates edges. Dragging two cards together is a spatial command.
7. **The agent evolves.** The system prompt supports phase-based behavioral shifts from aggressive creation (early canvas) to synthesis (middle) to critical refinement (mature canvas). The synthesis trigger at 5+ cards injects context that shifts agent behavior.
8. **Background work is visible.** Long-running tasks are represented as first-class objects on the canvas with pulsing status indicators. Research results cascade as individual cards that find their semantic place.
9. **External actions are narrow and explicit.** Google Calendar is the single external integration surface.
10. **The canvas remembers.** State snapshots enable replay — the thinking process is watchable.

## Session configuration

```javascript
import { GoogleGenAI, Modality, Behavior, FunctionResponseScheduling, EndSensitivity } from '@google/genai';

// v1alpha required for Proactive Audio and NON_BLOCKING tool behavior
const ai = new GoogleGenAI({ httpOptions: { apiVersion: 'v1alpha' } });

const config = {
  responseModalities: [Modality.AUDIO],
  systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
  tools: [{
    functionDeclarations: [
      // Canvas tools: default BLOCKING behavior guarantees silence during execution.
      // Upgrade path: add behavior: Behavior.NON_BLOCKING for FunctionResponseScheduling control (see spec §5.4).
      { name: 'create_card',    /* ... */ },
      { name: 'move_artifact',  /* ... */ },
      { name: 'update_artifact', /* ... */ },
      // Action tools: blocking (default) — model waits for confirmation
      { name: 'create_calendar_event', /* ... */ },
      { name: 'start_research_job',    /* ... */ },
    ]
  }],

  // Native audio features — technical differentiators
  proactivity: { proactiveAudio: true },          // Model decides when to speak vs silently act
  thinkingConfig: { thinkingBudget: 512 },         // Reasoning for spatial decisions

  // Transcription and session management
  outputAudioTranscription: {},
  inputAudioTranscription: {},
  sessionResumption: {},
  contextWindowCompression: { slidingWindow: {} },

  // Voice and activity detection
  // NOTE: Do NOT set languageCode with native audio models — they auto-detect language.
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

**Important:** Proactive Audio may suppress all output (including tool calls) for speech it classifies as irrelevant (Proactive Audio is topic/relevance-based, not device-directedness detection). If the agent fails to create cards during thinking-aloud, disable Proactive Audio and rely on the system prompt + SILENT scheduling for silent crystallization.

## Local development

### Prerequisites

- Node.js 20+
- npm or pnpm
- A Gemini API key (obtain from [Google AI Studio](https://aistudio.google.com/apikey))
- A Google Cloud project with Firestore and Calendar API enabled
- OAuth 2.0 credentials for Google Calendar access

### Environment variables

Copy `.env.example` to `.env.local`:

```bash
# Gemini
GEMINI_API_KEY=your-api-key
GEMINI_MODEL=gemini-2.5-flash-native-audio-preview-12-2025

# Google Cloud
GOOGLE_CLOUD_PROJECT=your-project-id
FIRESTORE_DATABASE_ID=(default)

# Google Calendar OAuth
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
GOOGLE_REDIRECT_URI=http://localhost:3000/api/auth/callback

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### Install and run

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in Chrome (recommended for microphone support).

### First-time setup

1. Click the microphone button to grant browser audio permission.
2. Speak naturally. The agent will begin creating artifacts on the canvas — you'll see ghost cards appear and solidify.
3. Watch the canvas organize itself as force-directed layout clusters related cards.
4. Use spatial references ("move that card on the left") to manipulate the workspace.
5. Say "research the latest compliance requirements" to launch a background research job.
6. Say "schedule a review for Tuesday at 2 PM" to create a Calendar event.
7. Use the replay scrubber to watch your thinking session evolve as a time-lapse.

## Google Cloud deployment

### Enable services

In your Google Cloud project, enable:
- Cloud Run API
- Firestore API
- Google Calendar API

### Deploy

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

Or manually:

```bash
gcloud auth login
gcloud config set project $GOOGLE_CLOUD_PROJECT

gcloud run deploy eureka-canvas \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --timeout=3600 \
  --min-instances=1 \
  --set-env-vars "GEMINI_API_KEY=$GEMINI_API_KEY,GEMINI_MODEL=gemini-2.5-flash-native-audio-preview-12-2025,GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT"
```

**Important:** `--timeout=3600` prevents Cloud Run from terminating the WebSocket connection during active sessions. `--min-instances=1` eliminates cold-start latency.

## Repository structure

```
.
├── README.md
├── spec.md
├── package.json
├── scripts/
│   └── deploy.sh
├── app/                    # Next.js app directory
├── components/
│   ├── Canvas.tsx          # Spatial canvas with pan/zoom and force-directed layout
│   ├── ArtifactCard.tsx    # Card rendering with ghost state + solidification animations
│   ├── DagEdge.tsx         # SVG dependency edges
│   ├── JobNode.tsx         # Background job status display with pulsing animation
│   ├── CanvasReplay.tsx    # Timeline scrubber for state snapshot replay
│   ├── TranscriptPanel.tsx # Live speech transcript
│   └── Controls.tsx        # Mic, text input
├── lib/
│   ├── live/               # Gemini Live API session management (Proactive Audio, session resumption)
│   ├── audio/              # AudioWorklet capture processor and playback utilities
│   ├── tools/              # Tool handlers (canvas, calendar, research jobs)
│   ├── layout/             # Force-directed semantic layout engine (d3-force)
│   ├── replay/             # Canvas state snapshot recording and playback
│   ├── firestore/          # Workspace persistence + snapshot storage
│   └── google/             # Calendar API client + Search grounding for research
├── public/
│   └── architecture.png    # Architecture diagram
├── docs/
│   └── cloud-proof.md      # Cloud deployment proof
└── .env.example
```

## Demo

The demo video (3:30) shows the following sequence:

1. **Problem framing** (0:00–0:12) — "What if AI didn't just talk to you — but thought alongside you?" Cut to: "Every AI today is a text box. We built something different."
2. **Conversation crystallization** (0:12–1:15) — The user describes a project. Ghost cards appear and solidify automatically, organized by force-directed semantic clustering. A synthesis card appears with a dashed border — an insight spanning multiple cards that the user never stated. The agent stays silent during speech (system prompt + FunctionResponseScheduling). After a pause, the agent speaks one topology-aware observation.
3. **Bidirectional spatial communication** (1:15–1:50) — The user silently drags two cards together. Without any voice command, the agent interprets the spatial intent and creates a dependency edge. Then the user makes a spatial reference, and the agent acts on the visible layout. The user interrupts mid-response. The agent pivots instantly: "Got it."
4. **Background research** (1:50–2:25) — A research job runs visibly with Google Search grounding while the user keeps working. Results are injected via `sendClientContent` and the agent announces findings. Individual finding cards ghost-in and find their semantic place via force simulation (research cascading).
5. **Calendar action** (2:25–2:55) — The user asks to schedule a meeting. A Google Calendar event is created. Then: canvas replay — a 10-second time-lapse showing the canvas evolving from empty to fully organized.
6. **Architecture proof** (2:55–3:20) — Brief view of the system architecture (server-proxy, three speech control layers, all SDK features labeled) and Cloud Run deployment.
7. **Close** (3:20–3:30) — "Eureka Canvas. The text box is dead. This is what comes after."

## Known limitations

- Optimized for desktop Chrome. Mobile browsers may have limited microphone support.
- The Gemini Live API is in preview. Occasional session drops or audio truncation may occur. The app handles reconnection gracefully via session resumption.
- Proactive Audio may suppress tool calls (not just audio) for speech the model classifies as irrelevant. This is a topic/relevance-based filter, not device-directedness detection. Silent crystallization works without Proactive Audio via the system prompt and FunctionResponseScheduling. If Proactive Audio interferes, disable it with one config change.
- NON_BLOCKING tools have a known API behavior where the model may generate speculative or duplicate audio in parallel with tool execution. FunctionResponseScheduling.SILENT mitigates this, and the system prompt forbids narrating tool calls as an additional safeguard. If narration persists, switching canvas tools to BLOCKING behavior eliminates the issue at the cost of model silence during tool execution.
- Calendar integration requires pre-authorized Google OAuth credentials.
- Canvas performance is optimized for up to ~50 artifacts. Force-directed layout adds minimal overhead but freezes after 2 seconds of settling.
- Synthesis cards rely on the model's reasoning quality. The system prompt instructs the agent to create synthesis cards only when genuine cross-card insights exist, but the quality of synthesis depends on the thinking budget and the complexity of the canvas state.
- Topology analysis is computed after force layout settles. If the layout doesn't settle cleanly (e.g., jitter from closely spaced cards), topology insights may be imprecise. The 2-second layout freeze mitigates this.
- The synthesis trigger at 5+ cards injects context via `sendClientContent` to shift agent behavior toward cross-card insights. Full dynamic system instruction mutation (phase-based prompt updates at multiple thresholds) is an upgrade path documented in the spec (§5.2.1) but not in the initial build.
- Canvas replay stores snapshots in memory and Firestore — large sessions may require pruning.
- If the Live API WebSocket fails to connect (e.g., during high load), a connection status indicator shows the current state. The demo video serves as a fallback for judges if the live deployment is temporarily unavailable.

## Troubleshooting

**No audio response:** Verify `GEMINI_API_KEY` is set and has Live API access. Check browser console for WebSocket errors. Try a different voice in the session config (Puck, Kore, Aoede). If Proactive Audio is suppressing all responses, try disabling it temporarily (`proactiveAudio: false`).

**Agent never speaks during pauses:** Check that `silenceDurationMs` is not set too high. Try reducing from 700 to 500. Verify Proactive Audio is not classifying all speech as irrelevant.

**Session drops:** The Live API connection resets after ~10 minutes. The app uses session resumption to reconnect automatically. If issues persist, refresh the page.

**Calendar errors:** Verify OAuth scopes include `calendar.events`. Ensure redirect URIs match your environment (localhost for dev, deployed URL for production).

**Artifacts not appearing:** Check the browser console for tool call errors. Ensure the backend is reachable and Firestore is enabled. If Proactive Audio is enabled and the agent isn't creating cards during thinking-aloud, it may be classifying the speech as irrelevant — try disabling Proactive Audio.

**Agent narrates every card creation:** Canvas tools use default BLOCKING behavior, which guarantees the model cannot speak during tool execution. If narration occurs after tool responses, strengthen the system prompt with explicit instructions: "ABSOLUTELY NEVER describe, acknowledge, or narrate tool calls." If upgrading to NON_BLOCKING + FunctionResponseScheduling.SILENT (see spec §5.4), be aware the model may generate speculative audio in parallel with tool execution — BLOCKING is the more reliable approach.

**Cards jittering:** Force-directed layout may oscillate with certain card configurations. Increase `alphaDecay` in the d3-force simulation to settle faster, or freeze layout after 2 seconds.

**No synthesis cards appearing:** Synthesis requires 5+ cards on the canvas and a user pause (2+ seconds of silence). The model may not find a genuine cross-card insight for every set of cards — this is by design. Verify the backend is injecting the synthesis prompt via `clientContent` after the card count threshold.

**Drag detection not creating edges:** Verify the proximity threshold (~80px) is correctly calibrated. The frontend must detect drag-end events and compute distance to the nearest card. Check that the `[CANVAS_UPDATE]` context injection is reaching the Live API session.

## Built for

- [Gemini Live Agent Challenge](https://geminiliveagentchallenge.devpost.com/)
- Submission category: **Live Agents**
- Mandatory tech: Gemini Live API + Google GenAI SDK + Google Cloud Run

*This project was created for the purposes of entering the Gemini Live Agent Challenge hackathon. #GeminiLiveAgentChallenge*

## References

- [Gemini Live API overview](https://ai.google.dev/gemini-api/docs/live-api)
- [Gemini Live API WebSocket reference](https://ai.google.dev/api/live)
- [Gemini Live API capabilities guide](https://ai.google.dev/gemini-api/docs/live-guide)
- [Tool use with Live API](https://ai.google.dev/gemini-api/docs/live-api/tools)
- [Session management](https://ai.google.dev/gemini-api/docs/live-session)
- [Proactive Audio configuration](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/live-api/configure-gemini-capabilities)
- [FunctionResponseScheduling](https://ai.google.dev/gemini-api/docs/live-api/tools)
- [Google Search grounding](https://ai.google.dev/gemini-api/docs/grounding)
- [Google Calendar API](https://developers.google.com/workspace/calendar/api/guides/overview)
- [Cloud Run WebSockets](https://cloud.google.com/run/docs/triggering/websockets)
- [d3-force](https://d3js.org/d3-force)

## License

MIT

---

**Eureka Canvas** — *The text box is dead. This is what comes after.*

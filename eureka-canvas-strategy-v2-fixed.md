# EUREKA CANVAS: WIN STRATEGY (HUMAN REFERENCE)

**Date:** March 16, 2026 — Submission Day
**Target:** Grand Prize ($25,000 + Google Cloud Next stage demo)
**Field:** 11,047 participants (as of submission day)
**Deadline:** 5:00 PM PDT today

**What this document is:** The strategic thinking behind the spec. Everything implementation-relevant has been integrated into spec v2.2 and the README. What remains here is judge psychology, competitive positioning, time management, and demo execution guidance — things that matter to you, not to agents.

---

## 1. THE META-GAME

### The 3-Second Rule

A judge watching the 87th video of the day decides in the first 3 seconds: "Is this another chatbot, or is this something different?" Your opening shot — a live canvas with cards materializing from voice in real time — must create INSTANT cognitive dissonance with every other submission. They expect a chat window. They see a living workspace. That delta is your entire competitive moat.

### The "I've Never Seen This" Factor

The single most predictive variable for Grand Prize wins is novelty that is VISIBLE. Not novelty buried in your architecture diagram — novelty that a judge SEES in the first 30 seconds. Ghost cards solidifying, force-directed clustering, synthesis cards with dashed borders, emotion-to-color mapping, drag-to-create-edge — these are all visible novelty. Most competitors will have invisible novelty ("we used a clever prompt chain"). You have novelty that is literally animated on screen.

### Google's Hidden Agenda

Google didn't spend money on this hackathon to see 8,000 wrapper apps. They built Proactive Audio, Affective Dialog, FunctionResponseScheduling, and thinking budgets — features most developers don't even know exist. **The Grand Prize will go to the project that makes Google's engineering investment look brilliant.** When a Google engineer on the judging panel sees you using `FunctionResponseScheduling.SILENT` on `NON_BLOCKING` tools with Proactive Audio as a fallback layer, they think: "Someone actually READ our documentation and built something we envisioned."

### The Competition Topology

Of 11,047 participants (as of submission day — up from 8,439 at last check):
- ~5,500 will not submit (typical dropout rate is 50%+)
- ~2,500 will submit incomplete/broken projects
- ~1,800 will submit basic voice chatbots (score 2-3)
- ~800 will submit competent projects with one hook (score 3-4)
- ~300 will submit strong projects (score 4-4.5)
- ~80 will be genuinely excellent (score 4.5-5.0)
- ~10-15 will compete for Grand Prize

The larger field increases the number of genuine contenders from ~5-10 to ~10-15. This doesn't change the strategy — you still win by being in a different category, not by being incrementally better in the same category. Most of them will be building vision-enabled tutors, translators, or customer support agents. A spatial canvas workspace that the agent perceives and manipulates is a fundamentally different category of entry. **You're not competing in the same race — you're running a different race entirely.**

---

## 2. DEMO EXECUTION NOTES

Everything below is about HOW to record, not WHAT to record. The shot-by-shot script is in spec §13.2.

### Recording Discipline

- Record each segment separately, 3 takes each.
- Splice the best takes with clean cuts.
- Keep agent responses SHORT — "Those risks cluster around the same root cause" is 9 words. Can't get cut off by premature `turnComplete` if you're already done.
- Each segment at 1.5x speed should still be comprehensible (that's how judges watch).
- Keep each recording session under 5 minutes of Live API session time to avoid connection drops.

### The Text Overlay Strategy

Every segment needs a small, non-distracting text overlay (bottom-right) naming SDK features. This is not decoration — it's a scoring mechanism. Judges for this hackathon are likely Google engineers. When they see "FunctionResponseScheduling.SILENT" appear as the agent silently creates cards, they feel validated. It turns invisible technical choices into visible judging criteria.

### The Final Frame

The last thing the judge sees before scoring is the last frame of your video. Make it count.

Full canvas. All cards organized. Semantic clusters visible. Research results integrated. Calendar event confirmed. Synthesis card glowing. Force-directed layout settled into equilibrium. The agent's voice: "That's Eureka Canvas." Your voice: "The text box is dead. This is what comes after."

Fade to black.

---

## 3. THINGS TO NOT DO

### Do NOT add features at the expense of demo polish
Every hour spent on a P2 feature is an hour NOT spent on recording a clean demo take. The demo is 70% of your score (40% Innovation is judged from the demo, 30% Demo is the demo itself). Budget time: 60% recording/editing, 40% last-minute code fixes.

### Do NOT let the agent narrate card creation
This is the cardinal sin. If the agent says "I'm creating a card about API migration" while creating the card, the entire thesis — that the canvas update IS the communication — collapses. Test this relentlessly.

### Do NOT over-demo
Show each feature ONCE, cleanly. Don't repeat the same interaction to prove it works. 3:30 is better than 4:00.

### Do NOT hide your Gemini SDK usage
Make it VISIBLE. Text overlays. Architecture diagram. README session config. Every SDK feature you use is a scoring opportunity.

### Do NOT neglect the Devpost text description
200-300 words. Hit every keyword — they are listed in spec §14.2.

---

## 4. THE SCORING MATH

### Base Score Optimization

| Criterion | Weight | Projected Score | Rationale |
|-----------|--------|-----------------|-----------|
| Innovation & Multimodal UX | 40% | 5.0 | Canvas paradigm + silent crystallization + Affective Dialog + force layout + ghost cards + synthesis cards + topology analysis + bidirectional spatial communication + replay with emotion gradient. No competitor will match this feature density. |
| Technical Implementation | 30% | 4.8 | Deep SDK usage (Proactive Audio, Affective Dialog, FunctionResponseScheduling, NON_BLOCKING, thinking budget, dynamic system instruction). Server-proxy. Firestore. Session resumption. Search grounding. Research cascading. The only deduction risk is if a feature misbehaves. |
| Demo & Presentation | 30% | 5.0 | Segment-recorded, scripted, thesis-driven. Canvas replay closer with emotion gradient. Architecture diagram. Cloud proof. |

**Base score: 4.94 / 5.0**

### Bonus Points

| Bonus | Points | Status |
|-------|--------|--------|
| Blog post (dev.to) | +0.6 | Write and publish today |
| Deploy script | +0.2 | `scripts/deploy.sh` in repo |
| GDG membership | +0.2 | Sign up + link profile |
| **Total bonus** | **+1.0** | |

**Final projected score: 5.94 / 6.0**

### Subcategory Prize Hedge

**IMPORTANT: The official rules state "A Submission can win a maximum of one prize."** If you win Grand Prize or Best of Live Agents, you are NOT eligible for subcategory prizes — they cascade to the next-highest-scoring project. However, your individual criterion scores still position you as a strong fallback candidate:
- **Best Multimodal Integration & UX** ($5,000): Your strongest axis — if Grand Prize and Best of Live Agents go to other entries
- **Best Technical Execution & Agent Architecture** ($5,000): Deep SDK usage — same fallback logic
- **Best Innovation & Thought Leadership** ($5,000): "Text box is dead" thesis — same fallback logic

The strategy is: aim for Grand Prize, with Best of Live Agents as primary fallback, and subcategory prizes as secondary fallback. You cannot stack prizes.

---

## 5. IF TIME IS CRITICALLY SHORT

If you have less than 4 hours before deadline, here is the absolute minimum for Grand Prize contention:

### Must Ship (in this order):
1. Canvas with card rendering (ghost → solid animation, synthesis card CSS)
2. Voice session with live audio (capture, playback, transcript)
3. `create_card` tool with SILENT scheduling (cards appear without narration)
4. Drag detection → edge creation (bidirectional spatial communication)
5. Force-directed layout (d3-force, ~50 lines)
6. One spatial reference resolution ("move that cluster")
7. One research job with Search grounding + cascading results
8. One Calendar event
9. Canvas replay (snapshot + scrubber)
10. Firestore persistence
11. Cloud Run deployment with `--timeout=3600 --min-instances=1`

### Then Immediately:
12. Record demo in segments (3 takes each)
13. Edit into 3:30 video
14. Write blog post on dev.to (see spec §14.1 for outline)
15. Create architecture diagram
16. Record 15-second Cloud proof
17. Fill Devpost submission completely
18. Submit by 4:00 PM PDT (1-hour buffer)

### Cut Without Hesitation:
- `group_artifacts` tool
- Multi-view transformations
- `delete_artifact` and undo
- Task DAG rendering
- Thinking budget indicator
- Any feature not visible in the demo video

---

## 6. INNOVATIONS NOT IN THE SPEC (REFERENCE ONLY)

These ideas were evaluated and intentionally excluded from the spec. They're documented here in case you want to revisit them, but they should NOT be built for this submission.

### Cognitive Waveform (excluded)
Each card embeds a tiny audio waveform of the 2-3 seconds of speech that created it. Gorgeous concept, but it touches the audio pipeline — the highest-risk component. The reward (tiny visual per card) doesn't justify the blast radius when hundreds of agents are coding in parallel.

### Zoom as Intent (excluded)
Zooming into a card = implicit "go deeper." High false-positive risk. Users zoom to read, not to request depth. During a demo, accidental zoom interpretation would look broken, not smart.

### Canvas Narration (excluded)
Agent narrates during replay with TTS. You can achieve 90% of this effect by narrating the replay yourself in the demo voiceover. Building TTS into replay is complexity for no incremental judge impact.

### Living Architecture Diagram (excluded)
Interactive SVG with hover states showing data flow animation. Nice polish but judges spend ~3 seconds on the architecture slide. A clean static SVG wins the same points.

### Multi-Perspective Synthesis (excluded)
Multiple view layouts (timeline, priority). Correctly P2 in the spec. Even with unlimited agents, the demo can't fit this — each view transformation needs 15-20 seconds of demo time.

### The Eureka Moment — Canvas Self-Organization (excluded)
A single connection collapses three clusters. Visually stunning but requires a very specific canvas state to fire. Too fragile for a live demo recording. Topology analysis (which IS in the spec) achieves a similar effect more reliably.

---

**Go win this thing.**

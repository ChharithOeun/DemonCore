# DemonCore — UE5 Vision

> Status: **PLANNING**. The UE5 project files live on a drive not yet mounted to the current Cowork session. This document is the scaffold — it will be filled in with concrete file paths, asset budgets, and Blueprint inventories once that drive is accessible.

## North star

A full **Unreal Engine 5 reimagining of Vana'diel** that:

1. Runs alongside the LSB private server (existing DemonCore v1.0.0 stack) as an alternate render surface
2. Is driven by the same AI infrastructure (Chharbot Python agent, MCPs) as the classic client
3. Uses Mandalorian-style virtual production techniques for cinematic dungeons / bosses
4. Ships with AI voice acting as placeholder for eventual live cast
5. Preserves gameplay parity with the classic FFXI mechanics — the UE5 client is a lens, not a fork

## Why UE5 (not UE4 or Unity)

- **Nanite** — realistic Vana'diel meshes at retail-comparable performance without manual LOD authoring
- **Lumen** — real-time global illumination, essential for dungeons and cutscenes that FFXI's original engine can't do
- **MetaHuman** — realistic race meshes (Elvaan / Hume / Mithra / Tarutaru / Galka) with proper facial animation
- **Chaos physics** — real cloth for capes/robes, real hair for the Mithra
- **Virtual Production tools built in** — Mandalorian's workflow requires this; UE5 has it native

## Three-layer architecture

Same shape as DemonCore's existing three-layer server design, extended one level for the render client:

```
┌───────────────────────────────────────────────────────────────┐
│  UE5 Vana'diel Client                                          │
│  - MetaHuman player + NPCs                                     │
│  - Nanite'd zone geometry                                      │
│  - Lumen lit dungeons                                          │
│  - Ashita-compatible input pipeline (multibox stays)           │
└──────────────────┬────────────────────────────────────────────┘
                   │  MCP: ue5_bridge (planned)
                   ▼
┌───────────────────────────────────────────────────────────────┐
│  Chharbot (existing DemonCore v1.0.0 agent)                    │
│  - Drives Blueprints via MCP tools                             │
│  - Same LLM stack (Ollama)                                     │
│  - Same rule-fallback library                                  │
└──────────────────┬────────────────────────────────────────────┘
                   │  MCP: ffxi_admin (existing)
                   ▼
┌───────────────────────────────────────────────────────────────┐
│  LSB server (unchanged)                                        │
└───────────────────────────────────────────────────────────────┘
```

## Planned subsystems

### `unreal/` (to be added when drive is mounted)

```
unreal/
├── Chharizard.uproject        # main project file
├── Config/
├── Content/
│   ├── Characters/            # MetaHuman + race meshes
│   ├── Zones/                 # Nanite'd geometry per zone
│   ├── UI/                    # UMG layouts matching Chharbar HUDs
│   ├── VFX/                   # Niagara systems for magic/skillchains
│   └── VirtualProduction/     # LED-wall specific stages
├── Source/
│   └── Chharizard/            # C++ modules
│       ├── Networking/          talks to lsb_admin_api sidecar
│       ├── ChharbotBridge/      MCP JSON-RPC handler
│       └── FFXI/                packet + game-state translators
└── Plugins/
    └── ChharbotUE5/           # First-party plugin, exposes UE5 state as MCP tools
```

## MetaHuman race adaptation (planned budgets)

| Race       | Body scale | Head base | Special notes                             |
|------------|-----------|-----------|-------------------------------------------|
| Hume M/F   | 1.0       | Default    | Baseline reference                        |
| Elvaan M/F | 1.15      | Elongated  | Height + ear geometry override            |
| Mithra     | 0.95      | Feline     | Custom head asset (MetaHuman + retopo)    |
| Tarutaru   | 0.55      | Chibi      | Aggressive head-to-body ratio; custom rig |
| Galka      | 1.3       | Beast      | Custom body + head; new anim retarget     |

Two heads per race (M/F where applicable), morph targets for face variation, LOD 0-2. Estimated ~2 GB per race, 12 GB total for base meshes.

## AI voice acting

- **Phase 1 (v2.0.0)** — Placeholder TTS via Chharbot. Every NPC dialog line runs through local text-to-speech (e.g., Piper TTS or Coqui XTTS-v2) tuned per race+gender. Chharbot picks tone (nervous quest-giver, gruff guard, hurt beastman) from the dialog context.
- **Phase 2 (v2.5.0)** — Voice-clone hooks. Users can drop reference audio for their favorite characters (Prishe, Aphmau, Trion) and Chharbot's LLM feeds cloned samples through the same pipeline.
- **Phase 3 (v3.0.0)** — Live voice cast slot. Structured hook points that let a human voice actor read a line, get pitch/timing baked, and ship it as the canonical line for that character.

## Server bridging

- LSB world state (mob positions, HP, party comp) syncs to UE5 via the existing `lsb_admin_api` sidecar. New WebSocket endpoint alongside the existing HTTP.
- UE5 client sends player intent (movement, actions) back via the same channel.
- **The LSB server stays authoritative.** UE5 is a render surface + input surface — no game-logic reimplementation.

## Mandalorian-style virtual production

- **LED volume stages** — build FFXI zones as static Nanite'd 3D environments, project on LED walls for in-camera cinematography
- **Real-time camera tracking** — track a physical camera through the volume; UE5 renders parallax-correct backgrounds live
- **Use cases** — cinematic mission cutscenes, boss-fight recap trailers, community-created machinima, promo videos

Not required for playable v2.0.0 — this is a differentiating capability for the content-creation side of the project.

## Legal risk register

| Risk                                              | Mitigation                                                  |
|---------------------------------------------------|-------------------------------------------------------------|
| SE trademark on "Final Fantasy XI" / "Vana'diel"  | Don't use SE marks in branding; DemonCore is fan-work       |
| SE model / texture asset reuse                    | Re-mesh + re-texture every asset; no direct rips            |
| Music / sound (Uematsu)                           | Original score commissioned or public-domain substitutes    |
| DMCA takedown of client                           | Ship as private-server tooling, LSB precedent applies       |
| Cease-and-desist from SE                          | Comply immediately; project stays offline until then        |

Plain: **this is a fan project.** SE could shut it down. Build accordingly — nothing that can't be rebranded / de-scoped fast.

## Timeline — dependencies

| Dependency                                    | Blocking? | Notes                                              |
|-----------------------------------------------|-----------|----------------------------------------------------|
| Cowork mount for UE5 drive                    | Yes       | Can't inventory current work without it            |
| Autonomous UE5 tooling (MCP for Blueprints)   | Yes       | Nascent — may need to build our own MCP server     |
| MetaHuman → MetaHuman Animator pipeline       | No        | Fallback: static poses first, animation later      |
| LED volume access                             | No        | v2.0.0 targets desktop first; volume is a stretch  |
| Legal review                                  | No        | Post-facto; don't monetize                         |

## First deliverable (v2.0.0)

Minimum shippable UE5 milestone:
1. One playable zone (Bastok Mines is small + iconic)
2. One playable character (Hume M/F baseline)
3. Basic movement + camera + chat (no combat yet)
4. UE5 client connects to LSB via existing sidecar
5. Chharbot can query UE5 client state via new `ue5_bridge` MCP

Combat, magic VFX, NPC dialog, cinematics — all v2.1.0+.

## Where existing DemonCore work slots in

- `chharbot/` (v1.0.0) — becomes the AI brain for UE5 NPCs and cinematics too
- `mcp/ffxi_admin/` (v1.0.0) — extended with world-state broadcast for UE5 subscribers
- `sidecar/lsb_admin_api/` (v1.0.0) — grows a WebSocket endpoint
- `binaries/xiloader-2.1.1.exe` — irrelevant to UE5 client; classic-client-only
- **New**: `unreal/` folder (waiting on drive mount)
- **New**: `mcp/ue5_bridge/` (post-drive-mount planning)

---

*This document is a planning stub. When the UE5 drive lands, expect concrete file paths, asset budgets by directory, actual Blueprint inventories, and a real roadmap with dated milestones.*

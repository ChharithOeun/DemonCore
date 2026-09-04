# Changelog

All notable changes to DemonCore will be documented here. Format loosely follows [Keep a Changelog](https://keepachangelog.com/).

## [1.0.0] — 2026-09-04

### First public release

Consolidates 7 sessions of work (2026-04-20 → 2026-04-21) into a single named repo. Previously staged as `outputs/FFXI/repo/` without a formal name; now branded **DemonCore**.

### Bundled

- `addons/ai_bridge/` — Ashita Lua addon, JSON-RPC listener for client state/actions
- `addons/xiloader_fixed/` — Ashita addon that chain-loads xiloader 2.1.1
- `binaries/xiloader-2.1.1.exe` — verified binary, MD5 `44FE5F23BF76E4E847946B5B76F1E061`
- `chharbot/` — local-LLM agent (Ollama or OpenAI-compatible), 24 pytests
- `lsb_version_sync/` — auto-match retail `CLIENT_VER`, 27 pytests (22 functional + 5 security)
- `mcp/ffxi_client/`, `mcp/ffxi_admin/`, `mcp/ffxi_chharbot/` — three MCP servers wrapping the entire client + server surface
- `sidecar/lsb_admin_api/` — FastAPI HTTP + named-pipe sidecar next to `map_server.exe`

### Docs

- `docs/AI-CONTROL-ARCHITECTURE.md` — two-bridge architecture rationale
- `docs/SECURITY-REVIEW.md` — 10-finding security pass over the v5+v6 stack
- `docs/SESSION-2026-04-20-v2-STATUS.md` → `SESSION-2026-04-21-v7-CHHARBOT-LOCAL-AGENT.md` — full session logs
- `docs/DEPLOY.md`, `ASHITA-INTEGRATION.md`, `WINDOWER-INTEGRATION.md`, `IDEAS-POL-ONE.md`
- `docs/AUTH-FIX-POSTMORTEM.md`

### Test coverage

- 51 tests total, all green as of v7 baseline
- Loopback socket tests for `chharbot` mean the agent is fully offline testable
- Security-focused tests for `lsb_version_sync` (path traversal, TOCTOU, atomic replace)

### Added in v1.0.0

- **README.md** — dynamic style with badges, banner, ecosystem cross-links, contact policy, credits
- **`assets/banner.png`** — 1280×640 blood-red neon on dark brick (molten core + skull-in-hex icons)
- **`.gitignore`** — private-server-grade coverage (no DB dumps, no credentials, no character data, no server logs)
- **`LICENSE`** — MIT + third-party attribution for xiloader/LSB/Ashita/Windower
- **INIT.bat / AUTO-SYNC.bat / PUSH-UPDATE.bat / INSTALL-AUTO-SYNC-TASK.bat** — same proven git infrastructure as Chharizard
- **Cross-linked** with Chharizard as sibling repo in the ecosystem

### Retired

- **`ffxi-autolaunch`** — folded into DemonCore. That repo should be archived on GitHub. Its launcher scripts live under `examples/` in this repo.

## Session history (pre-v1.0.0)

Preserved verbatim in `docs/SESSION-*` for the record.

- **v1-v2** (2026-04-20) — diagnosed and fixed guest-password hash; identified xiloader-version floor
- **v3** (2026-04-20) — installed verified xiloader 2.1.1 with versioned backup
- **v4** (2026-04-21) — proved end-to-end retail chain: xiloader → FFXiMain.dll → live FFXI window
- **v5** (2026-04-21) — designed two-bridge AI control architecture; landed stub addons, sidecar, MCPs
- **v6** (2026-04-21) — built `lsb_version_sync` (first-in-community auto-match)
- **v7** (2026-04-21) — shipped `chharbot/` local-model agent; 10-finding security pass; 51 tests green

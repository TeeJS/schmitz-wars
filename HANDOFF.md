# HANDOFF — Porting sol-conflict-revolution to GDScript

**Date:** 2026-09-02
**Author:** Lord Vader (chair of the port-evaluation room)
**Status:** Evaluation complete. Decision taken. **No code written yet.**

---

## 1. Decision

Port **sol-conflict-revolution** (Godot 4.7.1 mono, C#/.NET 8) to **GDScript** in
**this repo** as a fresh, clean, non-Mono Godot 4.7 project.

| Question | Answer |
|---|---|
| Is the port feasible? | **Yes.** No hard .NET blockers found (see §4). |
| Is it necessary? | **Yes, for a web build.** Godot 4 C# has no web export (see §2). |
| Approach | Straight translation. Same architecture, same rules, same 2-side day-tick model. |
| What must be preserved | **Manual fidelity.** The source repo's CLAUDE.md rule 0 ("the rule AND the implementation both match the manual") carries over verbatim. |

## 2. Why GDScript — the web-export constraint (Confirmed)

The driver is a **browser-playable build**.

> "Projects written in C# using Godot 4 currently cannot be exported to the web."
> — Godot docs, *Exporting for Web* (stable), verified 2026-09-02

Root cause: the .NET WASM runtime must be the main module and cannot be
dynamically linked into Godot's WASM. A community fork
(`ComplexRobot/godot-dotnet-web-export`) patches it but lacks GDExtension support
and has globalization gaps — not a shipping foundation. Forum threads from
July 2026 confirm nothing changed for 4.7.

The only alternatives to GDScript are GDExtension C++ (far more work) or Godot 3.

Sources:
- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- https://godotengine.org/article/platform-state-in-csharp-for-godot-4-2/
- https://github.com/godotengine/godot/issues/70796
- https://github.com/ComplexRobot/godot-dotnet-web-export

## 3. Source inventory — `D:\Github\sol-conflict-revolution` @ `11c1b36`

Godot 4.7.1 mono, `net8.0`, **zero NuGet packages** beyond `Godot.NET.Sdk`.

### Size

| Area | Files | Lines |
|---|---:|---:|
| `backend/` — game logic, no Godot UI | 50 | 16,038 |
| `frontend/` — windows, galaxy map, GID bar | 30 | 9,134 |
| root — `GameManager.cs`, `Menu.cs` | 2 | 647 |
| `.tscn` scenes | 18 | — |
| `data/*.json` (from Python parsers of the original `.DAT` tables) | 14 DTO types | 2.8 MB |
| **Total C#** | **82** | **~25,800** |

### Largest files

| File | Lines |
|---|---:|
| `backend/Mission.cs` | 2,640 |
| `backend/Planet.cs` | 1,642 |
| `frontend/UIManager.cs` | 1,012 |
| `backend/TacticalBattle.cs` | 968 |
| `frontend/FleetWindow.cs` | 905 |
| `frontend/DraggableWindow.cs` | 884 |
| `frontend/EconomyWindow.cs` | 883 |
| `backend/DayZeroGenerator.cs` | 873 |
| `backend/AiManager.cs` | 693 |
| `backend/StoryManager.cs` | 659 |
| `backend/OrderManager.cs` | 607 |
| `backend/FleetBattleManager.cs` | 549 |

### Backend subsystems (all must be translated)

Mission (2,640), Planet (1,642), TacticalBattle (968), DayZeroGenerator (873),
AiManager (693), StoryManager (659), OrderManager (607), FleetBattleManager (549),
Character (452), RuleManager (420), BombardmentManager (406), ForceManager (380),
MilitaryCatalog (370), StrategicTickManager (353), IntelManager (347),
AssaultManager (285), BlockadeManager (279), AgentDroid (260), LoyaltyManager (251),
SeedManager (223), RepairManager (222), ShipDamage (212), ResearchManager (194),
VictoryManager (193), InformantManager (186), DebugKeys (180), CaptivityManager (149),
Economy (145), GameSignature (141), SmugglingManager (135), MissionCatalog (133),
MissionTableManager (124), FacilityCatalog (124), GalaxyFactory (120), Unit (115),
SideLotteryManager (106), GameMessage (98), EventBus (89), UprisingTable (85),
plus `backend/Packs/` (347).

### Frontend windows (all must be translated, 18 scenes)

UIManager, FleetWindow, DraggableWindow, EconomyWindow, DefenseWindow, SectorWindow,
MessageWindow, MilitaryDataEditor, Gid, GalaxyMap, BattleResultsWindow,
BattleAlertWindow, GidKey, TacticalView, GalaxyOverviewWindow, MissionWindow,
FleetStatusWindow, PersonnelFinder, DefenseFacilityStatusWindow, GidBar,
ObjectivesWindow, PlanetFinder, CharacterStatusWindow, UnitStatusWindow,
PlanetWindow, TransitConfirmWindow, InGameMenuWindow, Buttons/ (3 files).

## 4. Construct audit — the translation tax

Grep counts over `backend/`, `frontend/`, root. Two auditors reached the same numbers.

| Construct | Hits | Risk | GDScript equivalent |
|---|---:|---|---|
| LINQ (`Where/Select/OrderBy/GroupBy/Sum/Any/First/ToList/ToDictionary`) | 421 | **HIGH** (volume) | `filter`/`map`/`sort_custom`/`reduce` or explicit loops. Verbose; each site needs care. |
| Generic collections (`Dictionary<>/List<>/HashSet<>`) | 352 | MODERATE | `Dictionary`/`Array`. Type safety is lost; use typed arrays where possible. |
| `System.Text.Json` attributes/options (`JsonPolymorphic`, `JsonPropertyName`, `JsonIgnore`, `JsonConverter`, …) | 43 | **HIGH** | `JSON.parse_string` is native, but polymorphic/attribute-driven mapping must be hand-written per DTO. |
| `JsonSerializer.Deserialize<T>` call sites | 16 (14 distinct DTO types) | **HIGH** | One dict→object hydration function per DTO type. |
| C# `event` / `Action<>` / `Func<>` | 49 + 18 | LOW | Godot `signal` / `Callable`. `EventBus.cs` (89 lines) is a typed hub → signals. |
| `record` / `struct` | 5 / 4 | LOW | Plain classes. |
| `GetNode<T>` | 128 | LOW | `$Path` / `get_node()`. |
| `[Export]` / `[Signal]` | 15 / 1 | LOW | `@export` / `signal`. |
| `FileAccess` | 22 | LOW | Same API in GDScript. |
| `_Process` / `_PhysicsProcess` overrides | 3 | LOW | Same. |
| `Random` | 1 site | LOW | `RandomNumberGenerator` with seed — determinism is easy to keep. |
| `async` / `Task<>` | **0** | none | — |
| `DllImport` / P/Invoke | **0** | none | — |
| `System.Reflection` | **0** | none | — |
| `unsafe` / `Span<>` | **0** | none | — |
| `ThreadPool` / `Parallel` | **0** | none | — |

**Conclusion: no hard blockers.** The cost is volume (LINQ + DTO hydration), not impossibility.

### DTO types deserialised (each needs a hydration function)

`List<Character>` (×2), `List<UnitStatRule>`, `List<SideRuleData>`, `List<SectorJsonData>`,
`List<PlanetJsonData>`, `List<MissionDef>`, `List<MilitaryUnit>`, `List<GameRuleData>`,
`List<FacilityStatRule>`, `List<DefenseStatRule>`, `IntTable`,
`Dictionary<string, MissionTableData>`, `Dictionary<string, LogisticsFile>`, generic `T`.

## 5. Risks

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| 1 | **GDScript on WASM is interpreted, single-threaded, no JIT.** `StrategicTickManager`/`Mission`/`Planet` run ~40 nested loops per strategic tick over all planets. Cost is **unmeasured**. Rough prior: GDScript is 10–50× slower than C# in tight loops. | **CRITICAL** | Vertical-slice gate (§6 step 1) measures it before any schedule is committed. |
| 2 | Web threads require SharedArrayBuffer + COOP/COEP headers. | LOW | Source uses 0 threads. Do not introduce any. |
| 3 | `user://` on web is IndexedDB, async-flushed. | LOW | Source has **no save/load system** (0 `user://` / `SaveGame` hits). Nothing to port; design for it later. |
| 4 | LINQ→loop translation errors silently change rules. | MODERATE | Keep the Python→JSON data pipeline as the contract; build a headless deterministic test runner and compare one-day outcomes C# vs GDScript on the same seed. |
| 5 | 2.8 MB JSON + galaxy BMPs in the `.pck`. | LOW | Acceptable for web. |
| 6 | Browser audio/input autoplay policies. | LOW | UI only. |

## 6. Next steps (in order — do not skip step 1)

| # | Step | Gate |
|---|---|---|
| 1 | **Vertical slice.** Create the Godot 4.7 non-Mono project here. Hydrate all 14 DTOs from `data/*.json`. Run **one strategic day** including the hottest `Planet`/`Mission` loop. Minimal galaxy-map UI. **Export to Web** and profile tick time at full production data. | Go/no-go on tick budget. |
| 2 | Translate remaining `backend/` (~16k lines), subsystem by subsystem, largest-risk first (Mission, Planet, StrategicTick). | Headless deterministic test passes per subsystem. |
| 3 | Translate `frontend/` (~9k lines, 18 scenes), window by window, **each checked against the manual passage that specifies it**. | Manual element checklist per window. |
| 4 | Web export of the full game; re-profile. | Playable in browser. |

Recommended practices for the new project (implementation lessons, not architecture):
- Headless, deterministic test runner driven by a fixed seed.
- Signal-based tick orchestration.
- Strict JSON error handling and index-building at load.
- Keep the Python parsers upstream in the source repo; **JSON is the contract**.

## 7. Effort (relative sizing only — NOT a commitment until step 1 passes)

| Phase | Estimate |
|---|---|
| Data layer (DTOs, JSON, LINQ→loops) | 3–5 days |
| Backend logic (Planet/Mission/Fleet engines etc.) | 7–10 days |
| Frontend UI (30 files, 18 scenes) | 4–6 days |
| Integration and testing | 3–4 days |
| **Total** | **17–25 days** |

## 8. Unresolved

- Actual GDScript/WASM tick cost — settled by step 1.
- Hosting/headers for the web build (only matters if threads are ever added).

## 9. Carry-over rules from the source repo

Copy these into this repo's `CLAUDE.md` before writing code:
1. **The rule AND the implementation both match the manual.** The window, its named fields, the gesture — all are spec.
2. Never invent a game mechanic. If the sources don't state it, stop and ask.
3. Research order: `.DAT` tables → `ENCYTEXT.DLL` → manual pages / `GAMEPLAY.md` → community RE → measurement.
4. Ask before any reverse engineering of `REBEXE.EXE`.
5. Label every statement as *how the game works* or *what the code does*.
6. Explicit approval before editing.

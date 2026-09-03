# Manual element checklists

This is the Step 3 research ledger for the C# frontend. It compares the manual text and labelled illustrations copied at sync `11c1b36` with the current `sol-conflict-revolution/frontend` implementation. It describes code state; it does not claim runtime verification.

Status legend: **Present** = named element and its interaction are represented; **Partial** = information or interaction exists but differs materially from the manual; **Missing** = the manual element is not represented; **Disabled** = the named control is visible but intentionally unavailable.

## 1. Galaxy Map and Galactic Information Display (GID)

Manual passages: Command Center, PDF pp. 21, 23 and 61–62 (manual pp. 22, 24 and 63–64); GID key and modes, PDF pp. 66 and 69–70 (manual pp. 68 and 71–72). Labelled figures: `manual/ILLUSTRATIONS.md`, figs. 2.3, 2.6, 2.7 and 3.8–3.10.

| Manual element, in the manual's words | C# frontend state |
|---|---|
| “Galaxy Map” in the Command Center | **Present.** `GalaxyMap.cs` supplies clickable system targets over the strategic map. |
| “Galactic Information Display” with the categories “LOYALTY”, “FLEETS”, “PERSONNEL”, “RESOURCES”, “MANUFACTURING”, “DEFENSE” | **Present.** `GidBar.cs` builds all six category buttons from `Gid.Categories`. |
| “Display Off” | **Present.** It is a real selectable GID mode and suppresses the information flare. |
| “Show Legend” icon / GID key | **Partial.** `GidKey.cs` builds a legend and updates it with the selected mode, but `GidBar.cs` creates it automatically as a taskbar-stowed window; the manual's explicit Show Legend control is absent. |
| The key's changing heading, such as “GALACTIC INFORMATION DISPLAY — POPULAR SUPPORT” | **Present.** `Gid.TitleFor(mode)` drives the legend heading. |
| Star “size corresponds to the amount” of the selected information | **Present, stylized.** `GalaxyMap.cs` uses tier-sized `+` flares. This is a text-glyph approximation rather than the manual artwork. |
| Popular-support sizes “LOYAL”, “OBEDIENT”, “DISLOYAL”, “HOSTILE” | **Present.** These are the four loyalty-tier labels in `Gid.cs`. |
| Color key: “RED — Alliance”, “GREEN — Empire”, “BLUE — Neutral”, “GRAY — Unexplored” | **Present.** The faction/unexplored colors are centralized in `Gid.cs` and used by the map and key. |
| Alliance Headquarters marked by a “white star”; only the Alliance player sees the hidden Alliance Headquarters | **Present.** `GalaxyMap.cs` draws the Alliance-HQ burst independently of Display Off and only for the Alliance player. |
| Select a GID category, then select one item from its pull-down list | **Present.** The category buttons open mode menus and set the shared active mode. |
| The GID selection applies to both Galaxy and Sector views | **Present.** Both `GalaxyMap.cs` and `SectorWindow.cs` read `Gid.ActiveMode`. |
| Loyalty: “Popular Support”, “Uprisings” | **Present.** Both modes are defined. |
| Fleets: “Idle Fleets”, “Fleets En Route” | **Present.** Both modes are defined. |
| Personnel: “Idle Personnel”, “Active Personnel” | **Present.** Both modes are defined. |
| Resources: “Mines”, “Refineries”, “Energy”, “Maintenance” | **Present.** All four modes are defined. |
| Manufacturing: “Idle Shipyards”, “Idle Training Facilities”, “Idle Construction Yards”, plus shipyard/training/construction capacity | **Present.** Six manufacturing modes are defined. |
| Defense: “Shield Generators”, “Ion Cannons”, “Laser Batteries”, “LNR Series I”, “Death Star Shields” | **Partial.** All five named choices exist, but `Death Star Shields` currently reports a constant zero; defense visibility uses current exploration rather than the manual's stale-intelligence model. |
| Keyboard shortcuts Alt+1 through Alt+9 for the first nine displayed modes | **Missing.** `UIManager._UnhandledInput` implements Alt+H and Alt+O only; no Alt+1…Alt+9 mappings exist. |
| Click a system on the Galaxy Map to open its Sector/System information | **Present.** Invisible planet buttons provide the click targets. |

Research confidence: **high** for named controls/modes, **medium** for exact visual fidelity because this pass is source inspection rather than a rendered comparison.

## 2. Fleet Window

Manual passages: fleet window overview, PDF pp. 48, 50 and 52 (manual pp. 49, 51 and 53); “Reading the Fleet Window,” PDF pp. 110–111 (manual pp. 112–113); fleet/ship commands and rearranging fleets, PDF pp. 114–123 (manual pp. 116–125). Labelled figures: `manual/ILLUSTRATIONS.md`, figs. 2.45, 2.46, 2.50, 2.54–2.56 and 3.54–3.55.

| Manual element, in the manual's words | C# frontend state |
|---|---|
| Open a fleet by double-clicking the Fleet icon in a system window | **Present.** The sector Fleet corner opens `FleetWindow`; the window lists fleets at that system. |
| “Fleets in System” list and selected fleet name | **Present.** The left column lists fleets; selecting one fills the right side. |
| Four tabs: “Capital Ships”, “Fighters”, “Troops”, “Personnel” | **Present.** All four named tabs are declared in `FleetWindow.tscn` and populated by `FleetWindow.cs`. |
| Capital Ships tab: each ship and the fighters/troops it can carry | **Partial.** Ships are listed, but the manual's carried-versus-capacity figures are not shown beside each ship. |
| Fighters tab: “number of fighter squadrons carried / total fighter capacity” | **Missing.** Fighter rows are listed without the paired carried/capacity total. |
| Troops tab: “number of troop regiments carried / total troop capacity” | **Missing.** Troop rows are listed without the paired carried/capacity total. |
| Personnel tab: characters assigned to the fleet | **Present.** Fleet characters are populated in the Personnel tab. |
| Double-click a ship/fighter/troop/personnel entry to “drill down” to its information | **Partial.** Information is reachable through each row's **Status** command, but the manual's double-click drill-down gesture is not implemented consistently. |
| A fleet or ship “in hyperspace” is shown by moving stars / a glow around its icon | **Partial.** Rows say “Enroute — arrives Day …” and are darkened; the moving-star field and icon glow are absent. |
| “Any time a fleet, or a ship within a fleet, is in hyperspace, it cannot receive orders” | **Present.** Order items are disabled while `Status.Enroute`. |
| Drag ships between fleets; drag a ship to blank space to create/rearrange a fleet | **Present.** Fleet and unit drag/drop paths support detaching, combining, and moving contents. |
| Drag fighters, troops, or characters onto a fleet that can carry them | **Present.** The fleet row accepts character/unit drops and loading logic enforces capacity. |
| Fleet menu: “Move”, “Confirmed Move” | **Present.** Both use target selection; Confirmed Move requests confirmation. |
| Fleet menu: “Planetary Bombardment” → “Target Military Facilities”, “Target Civilian Facilities”, “General Bombardment”, “Destroy System” | **Present.** All four named choices exist, with eligibility and Death Star gates. |
| Fleet menu: “Planetary Assault” | **Present.** It is enabled only when assault conditions permit and resolves through `AssaultManager`. |
| Fleet menu: “Rename” | **Disabled.** The item is visible but no rename implementation exists. |
| Fleet menu: “Encyclopedia” | **Disabled.** The item is visible but no Encyclopedia window exists. |
| Fleet menu: “Status” | **Present.** It opens `FleetStatusWindow`. |
| Fleet menu: “Scrap” and the confirmation “Are you sure you want to scrap the following units?” | **Present.** It opens a confirmation and reports the refined-material return. |
| Built-ship menu: “Move”, “Confirmed Move”, “Create Fleet”, “Rename”, “Encyclopedia”, “Status”, “Scrap” | **Partial.** Move, Confirmed Move, Create Fleet, Status, and Scrap work; Rename and Encyclopedia are visible but disabled. |

Research confidence: **high** for controls and command wiring, **medium** for drag gesture parity because it has not yet been exercised in a running build.

## 3. Create Mission and Mission Status windows

Manual passages: assembling a mission, PDF pp. 100–101 (manual pp. 102–103); mission table, PDF pp. 103–106 (manual pp. 105–108); tracking missions, PDF p. 107 (manual p. 109); persistent missions, PDF p. 108 (manual p. 110). Labelled figures: `manual/ILLUSTRATIONS.md`, figs. 2.34–2.35 and 3.47–3.51.

| Manual element, in the manual's words | C# frontend state |
|---|---|
| Right-click selected character(s) or SpecForces and choose “Mission” | **Present.** Character and eligible unit menus launch mission targeting. |
| “the cursor changes to cross hairs”; select a target system by clicking “any area of blank space” in its window, or select the particular character/facility/unit required | **Present.** `StartMissionTargeting` accepts a system or object target and resolves fleets to their system. |
| “Create Mission” window | **Present, simplified.** It is a generated `ConfirmationDialog`, not a dedicated manual-layout scene. |
| Create Mission “Target” field | **Present.** It names the system and, for object-specific missions, the selected person/facility/unit. |
| Create Mission team/agent portraits or names | **Present as text.** The dialog lists the selected team by name rather than using the original portrait treatment. |
| “Select Mission” tab and mission list showing only missions available to that character/SpecForce for that target | **Partial.** The legal-filter behavior is present in an OptionButton, but there is no Select Mission tab or manual-style mission list. |
| “Decoy” tab and assignment of qualified team members as decoys | **Partial.** Decoy checkboxes work and are set before launch, but they are inline rather than on the manual's Decoy tab. |
| “Encyclopedia” control in Create Mission | **Missing.** No Encyclopedia control/window is provided. |
| “Assign” and “Cancel” | **Partial.** ConfirmationDialog provides accept/cancel behavior, but the accept button is not explicitly labelled “Assign” in code. |
| Transit time / units in hyperspace after assignment | **Present.** The dialog reports transit days and launch creates real mission travel time. |
| Double-click the Mission icon to bring up the Mission window | **Present.** The sector Mission corner opens `MissionWindow`. |
| Mission window may contain “more than one mission on a given system” | **Present.** It lists every unfinished player mission against the system and names each team. |
| Separate status for “AGENTS” and “DECOYS” | **Present.** Dedicated tabs/labels separately list operatives and decoys. |
| Mission progress/status, including hyperspace and persistent-mission progress | **Present.** Rows show travel days, attempt count, and Diplomacy support percentage. |
| Moving-star field indicates the mission team is “in hyperspace” | **Partial.** Status text reports “in hyperspace, …d out”; the moving-star visual is absent. |
| Right-click Mission icon: “Status”, “Encyclopedia”, “Abort” (and continue a persistent mission when applicable) | **Partial.** Status and per-mission Abort exist; Encyclopedia is visible but disabled. Persistent missions continue automatically, but there is no separately named Continue command. |
| “you cannot give orders to units in hyperspace” | **Present.** Abort is disabled until the team arrives, both in the icon menu and status rows. |
| Aborting/continuing applies to the selected mission when several share a system | **Present for Abort.** Each Abort entry names its mission/team. Continue is automatic rather than a selectable control. |

Research confidence: **high** for create/status controls and mission-menu wiring, **medium** for original visual arrangement because it has not yet been rendered side by side.

---

Priority pass delivered first at Lord Vader's request. The remaining fifteen window checklists follow below as the source/manual sweep continues.

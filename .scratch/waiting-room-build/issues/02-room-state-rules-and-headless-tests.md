# 02: The room state: rules and headless tests

**Spec:** `.scratch/waiting-room/spec.md`, section 0 ("One source of truth"), sections 5 to 8 for the rules, and Testing Decisions. Vocabulary from `CONTEXT.md`: pick, hold, booking, ready-up, notice board, Random.

**What to build:** The host-owned room record and every rule of the waiting room, as a plain script with no scene, node, Steam, or transport dependency, driven by commands and checked by a headless test script that prints `PASS`. This is the slice's one testing seam and the module every later ticket renders from; get it right here so the views never contain a rule.

Per player, in arrival order: Steam id, display name, palette (01/02/03), pick (a vehicle or none), hold (a named role, Random, or none), seated (a chair or none). Commands in: arrive with an identity; leave; pick, drop, switch; take, drop, swap a role; sit, stand; tick the countdown; return from the test area. Configuration: the count the room waits for (three by default, `N` under `--min-players`). Outputs: the replicated state, the derived facts (whether a booking exists and which vehicle, the notice board's line, whether the countdown is running and where it is, the dealt roles at launch), and the events the views react to (booking formed and dissolved, countdown started and cancelled, launched with the deal).

Rules the record must enforce: a booking forms on the N-th matching pick and dissolves on any drop, switch, or departure, never on arrival; the role column is dead without a booking and every hold releases when it dissolves; a taken role rejects a second taker, ties resolve in receive order, Random accepts any number of holders; the notice board line follows the spec's priority ("Waiting for 2." / "No booking." / "Roles: 2 of 3." / "Seated: 1 of 3." / "Monster truck. 3."), counting out of N; the countdown starts only when every condition holds and is cancelled by any stand, pick change, hold drop, or departure; the deal at the end of the count gives every Random holder a distinct remaining named role and leaves named holders untouched; return from the test area clears picks, holds, and seats; a departure frees the leaver's pick and hold and never reshuffles the survivors' palettes.

The test is a headless `SceneTree` script run with `godot --headless --path . --script <test>`, in the shape of the repo's existing asset verifier, asserting literals (the notice board line, whose name is on a role, whether a booking exists) and never reaching into nodes, the `MultiplayerAPI`, or Steam. No test framework.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] The room-state script loads and runs with no scene tree, no autoload, no Steam, and no network.
- [ ] Arrival order deals palettes 01/02/03; a departure never reshuffles the survivors.
- [ ] A booking forms only on the third matching pick (N-th under `--min-players`), dissolves on any drop, switch, or departure, and an arrival never dissolves it.
- [ ] Without a booking every take is rejected; on dissolution every hold is released; a taken role rejects a second taker; same-frame ties resolve in receive order; Random accepts any number of holders.
- [ ] The notice board line follows the stated priority and counts out of the configured N.
- [ ] The countdown starts only when the room holds N players, a booking exists, every player holds a named role or Random, and every player is seated; any stand, pick change, hold drop, or departure cancels it and nothing was dealt.
- [ ] The deal at the end of the count gives every Random holder a distinct remaining named role and leaves named holders untouched; named plus dealt always sums to N.
- [ ] Return from the test area clears everything and the line reads "No booking." (or "Waiting for …" if short).
- [ ] A departure frees the leaver's pick and hold.
- [ ] The headless test script runs green and prints `PASS`; the command to run it is written in one sentence at the top of the script.

## Comments

**From ticket 01 (orchestrator).** Autoloads do load under `--headless --script`, so every headless test inits Steam (works, prints identity). Headless scripts that fail an `assert` hang forever instead of exiting (same shape as `verify_assets.gd`); run them with a timeout. The very first `--headless --import` after the extension appears exits with 0xC0000005 at shutdown; the second import and all runs are clean. GodotSteam GDExtension for Godot 4.4+ lives on Codeberg (`v4.22.1-gde`); the vendored `addons/godotsteam/` is trimmed to win64.
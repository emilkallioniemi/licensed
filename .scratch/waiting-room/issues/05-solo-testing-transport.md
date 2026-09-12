# 05. Testing alone: a second transport or a fake

Type: grilling
Status: resolved
Blocked by: 01
Map: ../map.md

## Question

Steam runs one account per machine, so Emil cannot open three instances of the game on his PC and have them meet in a Steam lobby. Yet every ticket after this one needs a multiplayer room to react to, and friends are not always online. How do we test a three-player room alone?

Options to weigh, informed by what GodotSteam on Godot 4.7 found:

- **Dev transport.** Keep `ENetMultiplayerPeer` behind a launch flag (`--transport=enet`) so the editor's *Run Multiple Instances* opens three windows on localhost. The room code never touches the transport directly, only `multiplayer`. Steam stays the only shipping transport (ADR 0002 holds); this is a test seam, and per ADR 0001 and the *Scaling* drift in `docs/design.md` it must never look like a mode.
- **Fake peers.** A debug flag that spawns bot learners and lets one instance pretend three are present. Cheaper, but proves nothing about sync.
- **Two accounts.** A second Steam account on a second machine or a Steam Deck. Real, but not always at hand.

Also decide the **debug override for launching with fewer than three**, which the map already requires: what the flag is and where it is honoured.

Deliverable: an answer naming the approach and the flag(s), and how a fresh session runs three learners in one room in under a minute.

## Answer

Decided with Emil, 2026-09-12.

**Approach: a development-only transport behind a launch flag. No bots.** `ENetMultiplayerPeer` on localhost, so the editor's *Run Multiple Instances* opens three windows on one PC that meet in one waiting room. Room code depends on `multiplayer` (the `MultiplayerAPI`) only; one autoload picks the peer at startup. Steam stays the only shipping transport (ADR 0002). Fake or bot learners are ruled out: they prove nothing about sync, spawn order, or RPC ownership, which is what every later ticket reacts to, and a bot in a seat is the *Scaling* drift (`docs/design.md`, ADR 0001).

**Steam is required in every case.** The dev transport does not run without a logged-in Steam client. All three local instances call `Steam.steamInitEx(480, true)` and succeed (one account, three processes); only the connection between them is swapped. If init fails, the game shows the "Steam is not running" state from ticket 01 regardless of transport.

**Flags.** Command-line user args (after `--`), so they work in the editor's per-instance Launch Arguments, from a script, and on the exported exe. Feature tags were rejected because they cannot be passed outside the editor.

- `--transport=enet`: use the dev transport. Absent, or `--transport=steam`: the shipping path. No other value.
- `--min-players=N`: allow ready-up with N players present instead of three. Honoured at the ready-up gate and nowhere else; booking board, role pickup, and reception desk behave exactly as with three. Independent of `--transport`, so it also lets Emil and one friend reach the stub over Steam. Named so it reads as "the room may launch short", never as a mode.

Neither flag has a UI, a menu, or a mention in the release notes.

**Finding each other on localhost: bind-or-join.** Every instance runs identical args. It tries to listen on a fixed port constant; if the port is taken, it connects to it instead. First window hosts, the other two join and arrive through the entrance. No `--host` flag, no per-instance config, no reception-desk involvement: inviting is a Steam-lobby fact and is tested only on the real path.

**Identity under the dev transport.** Steam name and avatar as normal (the async `avatar_loaded` path stays exercised), with the peer id appended to the name for peers other than the host: "Emil", "Emil (2)", "Emil (3)". The suffix exists only under `--transport=enet`.

**The real-Steam check.** Emil has no second Steam account or machine at hand; his brother may try the build. So the invite flow (reception desk, ticket 06) gets its real test "when a friend is online", written into that ticket as a note, not a blocker. Everything else is testable alone.

**Three learners in one room in under a minute, from a fresh clone.** The run-instance config lives in `.godot/editor/` (gitignored), so it is set once per clone:

1. Godot: *Debug → Customize Run Instances…*, tick *Enable Multiple Instances*, set the count to 3.
2. *Main Run Args*: `-- --transport=enet`. Optionally give each row a `--position X,Y` so the windows do not stack.
3. Press Play. Window 1 hosts; windows 2 and 3 join and walk in through the entrance.

Without the editor: run the exported exe (or `godot --path .`) three times with `-- --transport=enet`.

## Comments

- 2026-09-12, from [The booking board](07-booking-board.md): **amendment to `--min-players`.** A booking now forms only when all three players in the room have picked the same vehicle, and the role column is dead until there is a booking. So "honoured at the ready-up gate and nowhere else" would leave a solo dev with no way to reach a live role column. `--min-players=N` is now the count the waiting room waits for *everywhere* it waits for three: the booking forms at N matching picks, the ready-up fires at N. The reception desk (room capacity, "N of 3") is unchanged; the flag still has no UI and still reads as "the room may launch short".

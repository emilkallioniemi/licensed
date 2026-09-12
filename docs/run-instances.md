# Three learners in under a minute

The waiting room holds exactly three players (ADR-0001). Steam runs one account per machine, so three editor windows cannot meet in a Steam lobby. The development transport puts them on localhost instead. Steam is still required: all three instances init against app 480 with the same account. Neither `--transport` nor `--min-players` has a UI, a menu, or a mention in release notes.

## Editor (once per clone)

The run-instance config lives in `.godot/editor/` and is gitignored, so it is set once per clone:

1. Godot: **Debug → Customize Run Instances…**
2. Enable multiple instances, set the count to **3**.
3. Main run args: `-- --transport=enet`. Optionally give each row a `--position X,Y` so the windows do not stack.
4. Press Play. The first window to bind the port hosts; the other two join. Walk around: three learners, three colours, name tags on the other two.

## Exe (or `godot --path .`)

Run the export (or the editor binary) three times with the same args:

```text
licensed.exe -- --transport=enet
```

Same bind-or-join: first process hosts, the next two join.

## Flags

User args after `--`:

- `--transport=enet` — localhost ENet. Absent or `--transport=steam` is the shipping Steam lobby. No other value.
- `--min-players=N` — the count the room waits for (1–3). Independent of transport. No UI.

Under `--transport=enet` the display names are the Steam name with the peer id appended for non-hosts: `Emil`, `Emil (2)`, `Emil (3)`.

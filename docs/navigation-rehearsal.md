# Rehearse the navigation track alone

This debug tool uses production track geometry, truck physics, attempt state and secured learners. It does not simulate human communication or prove the game is fun.

The active track is now the monster truck stadium. Find Car Crunch, Ring Run and Big Air in the navigator's book. The final live lane has a real jump gap: line up and build speed; crawling into it fails. Wrecks compress under the truck and reset on retry. Pyrotechnics are show effects, while falling into the excavated stunt pits loses the shared attempt.

From the repository, run:

```powershell
& Godot_v4.7.2-stable_win64_console.exe --path . res://dev/solo_rehearsal.tscn -- --rehearsal
```

The shipping game still requires three humans. The rehearsal scene is excluded from exports.

- **F1 / F2 / F3**: inspect steering, speed or navigation. Only navigation sees the modeled field book; Tab raises/lowers it. **Q / E**, arrow keys or Page Up/Down turn its physical pages. Find the landmark in the contents, then turn to its inspection entry; progress never turns pages automatically.
- **W / S**, **A / D**: normal speed and steering inputs. Steering holds its angle.
- **R**: hold to right a settled rollover on supporting road. It cannot rescue a lethal fall.
- **F4**: toggle operating both driving roles with one keyboard. This convenience is for inspecting the course, not measuring cooperation.
- **F5**: start recording both driving roles from the start of the same track; press again to stop.
- **F6**: restart the same layout and toggle replay. The selected role remains live; the other driving role replays its recording. Choose F3 to replay both and inspect the navigator's experience. Inputs are replayed, not truck transforms, so your live changes can cause the recordings to diverge.
- **F7**: disable the selected contribution. Disabled steering holds its current angle; disabled speed releases pedals; disabled navigation hides the report. This does not model a human choosing to remain silent.
- **F8 / F9**: restart the same layout / start a new layout and clear recordings.
- **F10 / F11**: save/load recordings and their layout to `user://dev-navigation-rehearsal.json`.
- **Escape**: exit the rehearsal.

First drive a successful baseline with combined controls, consulting the report at each junction. Record it. Replay speed while handling steering, then replay steering while handling speed. Inspect the navigation view during full replay. Finally disable one contribution and compare. Look for idle stretches, unclear directions, unavoidable falls and collisions you cannot reverse out of.

Follow this with a short three-human session. Rotate roles and ask whether each player made decisions the others depended on; do not treat replay success as evidence of multiplayer enjoyment.

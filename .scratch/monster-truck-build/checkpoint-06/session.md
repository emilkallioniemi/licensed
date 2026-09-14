# Revised checkpoint 06: three-human Steam playtest

Status: revised truck integrated; Windows/macOS prerelease preparation. The earlier build was played and prompted this revision; it is not the build to test again. Human acceptance remains pending. The revised short test can produce a shared pass; durable personal licenses remain later work.

## Build and setup

Use the revised Windows/macOS ZIPs alongside this procedure. All three people, including the user, need the same manifest/source hash and separate Steam accounts. Keep Steam running, launch via the packaged launcher, invite/join at reception, choose monster truck, and sit. Do not use ENet for human acceptance. Start at 1280×720, 60 FPS, existing 60 Hz physics; record any changes. Record build hash, OS, host, settings, connection type and trial identifiers A/B/C.

The optional `--checkpoint-diagnostics` flag records local JSONL files in Godot's user-data directory. Keep logs and consensually recorded video/voice per trial. The existing `summarize.py` reports observed probe round trips, variation/timeouts, frame intervals and input acknowledgement ages. Those are not one-way latency, Steam packet loss, or click-to-photon latency. Use video for visible response; report unavailable measurements as unavailable.

## Learn and pass

Hold Space while walking against the truck to climb. Aim the centre crosshair at a highlighted seat and press E; E also deliberately leaves a seat. Everyone seated shares the elevated truck camera.

| Responsibility | Controls |
| --- | --- |
| Steering | A/D left/right; unwind the wheel yourself. |
| Speed | W forward; S brake then reverse. Release to slow. |
| Balance | A/D lean left/right; W/S forward/back over bumps. Directions are truck-relative. |
| Swap | Stop, press 1 steering / 2 speed / 3 balance. The other occupant presses Y to accept or N to refuse. Requests expire. |
| Recovery | When prompted, hold R for two seconds. Release driving controls and let an overturned truck settle first. |

Follow the shared instruction and yellow target: turn right, cross the bumps from left to right, then park lengthways inside the yellow bay and stop for two seconds. Corrections and reverse approaches are allowed. Recoveries and cone contacts lower the rating but permit passing. The timer is six minutes. Observe the shared result, then unanimously Retry. Escape offers a unanimous concession.

First play three attempts, rotating responsibilities so each person tries all three. Record whether controls make sense within a minute and what prevented any pass. Include at least one successful test and one recovery followed by a pass. Nobody should need to dismount to find out where to drive.

## Compare cooperation

After familiarisation, repeat a matched attempt with active balance, then with the balance player connected but idle; alternate the order on a repeat. Record where balance helped, where it was engaging or idle, and whether it was merely busywork. Do not infer fun from passing or force the role to matter with artificial input gates.

Rotate the host and repeat the relevant steering/speed/balance comparisons. Each person reports concrete examples: what was funny, what felt unfair, when their contribution mattered, whether they could see the destination, and whether they wanted another attempt. A dull or dispensable balance role means revise before expanding the route.

## Network and interruption checks

Cover simultaneous attempts to occupy one seat; accepted/refused/expired swaps; movement cancelling a request; held input during handover; secure seating during impact/rollover; and guest recovery followed by shared progress/result/retry. Check mixed result choices and withdrawing concession as well.

Repeat relevant cases on ordinary and adverse Steam connections. If an already-authorized network shaper is available, use nominal 75 ms added delay each direction, ±25 ms variation and 2% datagram loss; record the actual configuration and observed diagnostics separately. Also cover 0.5- and 2-second blackouts with a held command released during the blackout. If no shaper is available, record the missing adverse check; low FPS is not a network impairment substitute.

Test guest loss and host loss during loading, driving and results. Survivors must return appropriately, without a partial test or host migration. Re-form three people between cases. No two-player acceptance run.

## Trial record

Build hash / settings / trial / host / responsibilities / connection profile:
Pass or failure / elapsed time / contacts / recovery / parking corrections:
Steering, speed and balance: understandable, responsive, engaging, useful?
Visibility and instruction problems / exact unfair or funny moments:
Active-versus-idle balance difference:
Desire to retry / rating motivation:
Video and log filenames / measured diagnostics / unavailable checks:
Retain or revise / specific next change / matched repeat:

Ticket 06 remains unaccepted until build-linked human evidence and material fixes are recorded. Tickets 09–28 remain deferred.

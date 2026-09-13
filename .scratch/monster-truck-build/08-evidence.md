# Ticket 08 evidence

Ticket/review base: `600dd5fb2e103d63a429c52d3069c7bbef7b85f2`. The user explicitly authorized 07–08 before human checkpoint 06. All other downstream expansion remains gated by 06. Agent scene and protocol fixtures do not establish human cooperation, enjoyment, fairness, or Steam feel.

## Integrated learner production

The original beveled learner is rebuilt with a tailored jacket, collar, pockets, seams, zip, learner badge, expressive white eyes/pupils/brows, swept hair, ears, lips and laced shoes. The three existing arrival palettes remain recognizable. Matching 512px portraits are generated from this same body and palette values, ready for the later physical license; there is no customization screen or card gameplay.

The editable Blender source and Python generator retain a portable articulated transform rig: pelvis, spine, head, shoulders, elbows, wrists, hips, knees, ankles, and two independent joints on each of five digits per hand. It is a rigid segmented humanoid hierarchy rather than a skinned deforming skeleton. The expressive style uses those visible segments deliberately. Godot `LearnerPose` owns pose transitions and two-bone contact; the visual owns palette and first-person visibility. Later people can reuse this rig and pose driver. Full emotes remain 22, the physical license remains 19, and the distinct examiner remains 23. The temporary examiner is repositioned to the revised seated pelvis so the new asset does not break his seat.

Idle/breathing/blinks, walking, jumping/falling/landing, boarding/climbing, take/seated/leave, loose-limb collapse, and recovery run on the same body. Host/prediction movement supplies support, grounded state, gait phase and look through the existing snapshots. Occupancy anchors the pelvis and torso to the truck while look turns the head; rendering cannot claim a control, move the collision body, or decide rescue. Hands bend all fingers and follow the actual wheel rim through a bounded regrip arc; pedal shoe toes contact modeled pads. Contacts are retained in truck-local space and resolved against the current rendered frame, avoiding a previous-frame world-point lag while driving. First-person draws those same world-space arms, hands and legs with ordinary depth testing, suppressing only the own face/neck/torso surfaces around the eye. There is no floating overlay hand rig or through-wall draw mode.

Ragdolls here are authored articulated presentation driven by host recovery, not a new limb physics simulation. Body collision and rescue remain the established host-owned capsule/contact behavior. The prone pose fits the retained ground/under-deck clearance and unfolds to full height after physical rescue; body scale remains one. Catastrophic physical destruction remains 25.

## Iteration and limits

- Blender runs natively because its sandbox process crashes before Python. Generator exports the editable blend, GLB, studio preview and three matching portraits. The anatomical rest proportions were tailored to the retained 1.75m standing eye and 1.2m seated eye; modeled seated eyes are within 0.07m. First-person FOV remains 88 degrees.
- Initial scene import passed. One initial native run exited without a final PASS and is not accepted evidence. A subsequent fixture variable-name parse error was fixed before rerunning; it is not a behavioral red.
- The initial actual occupied eye images exposed collars covering the lower view and physical instruments despite passing contact assertions. The shorter torso/neck plus own torso-surface exclusion close that visual defect; actual occupied forward and down-look views must both be inspected.
- A real turned-wheel regression found hands following a spoke beyond arm reach. Bounded sliding/regrip arcs retain actual rim contact through the steering range without changing axle behavior.
- `08-prone-red.log` measured limbs 0.43m below ground and a head above recoverable clearance. The corrected full articulated pose passes `08-prone-green.log`, with grounded bounds and complete upright recovery; no scaled-standing substitute.
- `08-late-tumble-red.log` found that a complete airborne snapshot arriving after the short impulse timer lost the loose-limb pose. `08-late-tumble-green.log` passes the persistent airborne presentation flag, with grounded/retry reset.
- Combining the driving/rescue setup with the independent concession fixture contaminated the latter’s assumed initial truck state. A separate fresh failure run passed; final validation keeps those scenarios separate without weakening their assertions.
- The macOS verification copy uses Godot 4.7.2 and the matching native GodotSteam 4.22.1 adapter. Shipping Windows addon/preset remains unchanged. Steam login is unavailable; actual three-world ENet runs are agent protocol/scene fixtures only.

## Final validation

- `08-suite-results.txt` and eleven `08-verify_*-final.log` files: each exits 0, with explicit PASS or zero-failures and no application/script/parse errors. Coverage includes RoomState, attempt/driving/recovery boundaries, Steam-client policy, learner motion, reception input, failure/choices, modeled truck presentation, actual collision/stair/rescue scenes, and the new learner rendered-bounds/recovery/late-snapshot/eye suite.
- `08-network-final.log`: native windowed three-world ENet run exits 0 after 50.01 seconds with both final PASS markers and no failed assertions or script errors. All three coloured learners walk via their own peer input. It exercises real boarding and switchback access, ordinary roof riding/jump/detachment, guest free yaw/pitch observed across peers, moving release, contention, delayed snapshots, driving/reverse/parking, gate impact, ejection/landing, physical entrapment/rescue, and guest-loss return.
- The same run verifies seated pelvis/cushion height and real bent thighs across all nine replicas; both hand/rim and shoe/pedal contacts at rest and during a turn; own visible world hands/head exclusion; and actual guest E retake before landing. `08-retake-red.log` proves the previously persistent tumble after that accepted retake; the final run passes all three observer assertions after the occupied branch and pose priority clear it.
- Final `08-occupied-{front,rear,pedals}-{eye,hands}.png` use actual own learner cameras at retained 88-degree FOV, with forward and down-look captures. Collars clear the view, steering knees clear the wheel, hand/rim and shoe/pad contact is visible, and the timer/direction/parking print remains readable. `08-occupied-cab.png` shows the three seated coloured bodies with the temporary examiner. `08-learner-{three-walking,boarding,jump,ejected,landed,trapped,rescued}.png` record real scene states. The under-deck trapped screenshot is naturally occluded by the truck; rendered-clearance assertions plus the ejected/recovered images document the full articulated transition without making the truck transparent.
- `08-source-manifest.json` records 16 final runtime/test/generator/model/portrait/preview/document hashes, each verified equal to the exact native verification copy. Generated UID/import metadata is retained, redundant `.blend1` is removed, Python compilation and `git diff --check` pass. Headless logs retain environmental sandbox log/editor-settings/certificate diagnostics and unavailable Steam login; those are not application acceptance or native Steam claims.
- Both code-review axes reviewed the fixed ticket base plus working/untracked changes. Standards found no remaining violations; Spec's missing shared head pitch and persistent ragdoll after airborne retake are fixed and verified. Full gesture/license gameplay, distinct examiner production, catastrophe limb physics/destruction and human online acceptance retain their later ticket ownership.

- `08-failure-final.log`: fresh native windowed three-world concession/aftermath/results/changed-choice/retry run exits 0 in 24.77 seconds with final PASS and no application failures. The guest throttle releases, guest wheels continue through host-owned aftermath, and all learner poses/occupancy and the truck reset on retry.
- `08-ready-final.log`: native windowed ready-up/announcement/cancel/restart/test-area-transition suite exits 0 in 11.22 seconds with final PASS and no script/audio errors. This suite runs windowed because the native headless TTS path is an existing environmental limitation.

## Refreshed checkpoint package

Local artifact: `export/checkpoint-06-modeled/licensed-checkpoint-06.zip` (61.0 MiB). SHA-256: `0e7237433698e990fe6af9076910472e3a1a5243cf55f1a670abf5e3d07b58ee`. Source-manifest digest: `f7b81c64c7a1ae92276562930d964d7ecf75d0d0a403f467124b63d63831f2ef`.

The retained `checkpoint-06/build.py` exported the source frozen after final source review, using Godot 4.7.2, the x86_64 Windows release template and matching export-only macOS GodotSteam adapter. `08-export-final.log` records a successful export without script/parse/export errors. `checkpoint-06/build-manifest.json` is the refreshed manifest; `build-manifest-historical.json` preserves the original 06 artifact's manifest. The session procedure and implementation README point at the modeled package. The old `export/checkpoint-06/licensed-checkpoint-06.zip` remains historical.

Both implementation and orchestrator independently verified all 177 source hashes against the current tree, all seven packaged file hashes against both disk and ZIP, identical manifest bytes, eight ZIP entries with clean CRCs, x86_64 PE signatures, exact shipping release DLL equality, and the archive SHA-256. The ZIP contains the Windows executable/PCK, release GodotSteam/Steam API DLLs, launcher, session procedure, summarizer and manifest. No macOS library, debug DLL, ENet launcher or `steam_appid.txt` is shipped. Editable Blender/generator assets remain in the repository.

Windows launch and three-human Steam acceptance remain unperformed on this Mac and pending in 06. This package is prepared locally; it was not published or externally shared. Exactly three humans on separate Windows/Steam accounts must perform the recorded checkpoint procedure before other expansion. All handling, sight, timing and cooperation candidates remain provisional.

## Handoff

- 06: Use the refreshed modeled ZIP/hash above for the actual Windows/Steam three-human session. No agent fixture substitutes for that gate.
- 19: Use the matching palette portrait assets and articulated wrists/digits for the physical license; no card gameplay is added here.
- 22: Implement the five full emotes on the shared rig, preserving first-person/world agreement and control restrictions.
- 23: Replace the explicitly temporary seated examiner with his distinct body, props and reactions.
- 25: Extend catastrophic destruction and physical aftermath; current recoverable ragdoll presentation is authored, with host-owned body collision/rescue.

All ticket 08 implementation criteria are verified; no implementation dependency remains. The separate 06 human gate remains pending.

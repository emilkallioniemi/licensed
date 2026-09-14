# Final monster-truck art and local packages — 2026-09-14

The user refined the target during integration: Hot Wheels-style proportions, a smaller body, bigger wheels and high clearance. The initial open-pickup packages in `export/revised-monster-truck-2026-09-14` are superseded. Use `export/monster-truck-high-body-2026-09-14`.

## Model and collision

The final body shell is 28% narrower, 20% shorter and lifted 1.1 m. The tyres are 45% larger; the deck is 2.7 m above the ground and the sparse roll cage reaches 4.65 m. There is no solid roof or rear staircase. Long exposed suspension, a small bonnet/intake and the open rear balance platform remain visible. Editable Blender source, GLB and studio previews were regenerated locally with Blender 5.2.1.

Seats and controls remain human-sized: steering (−0.864,2.7,−1.04), speed (0.864,2.7,−1.04), balance (−0.864,2.7,1.04); examiner (0.864,2.7,1.12). Wheel centres are x±2.4, y1.6, z±2.1, with radius1.6 and collision width1.9. Blocking/recovery hulls are 6.8×4.8×7.4 m. Suspension probes, tyre roll animation, instrument placement, seats and shell/cage collision follow the revised geometry. Higher Space-climb contact reaches the body between the oversized tyres. No gameplay progression or later player redesign was added.

## Verification

- Blender source regeneration and Godot import succeeded; inspected `assets/monster_truck/preview_front.png` and actual seated/result captures under `revision-*.png`.
- Actual three-peer rendered driving completed turn → bumps → parking, after a guest-held rollover recovery, with a shared pass and retry. That run caught the between-wheel climbing gap introduced by the higher floor. After fixing it, `verify_boarding_scene.gd` passed all three approaches, and `verify_launch_network.gd -- --revision --revision-controls` passed aimed seating, guest exit/reboarding, rollover/off-course recovery and guest-loss return.
- Truck presentation, recovery scene, attempt state and balance/swap tests passed with the new asset/coordinates. The old rooftop footing fixture now exercises the open bed; an unsecured rider may land safely on the truck or ground. Secure seated collision/rollover behavior remains verified.
- Export builder completed both platforms with no script/parse/export errors, checked matching source hashes, archive CRCs and contents, Windows PE architecture, universal Mac binaries and strict deep ad hoc signature.
- Extracted Mac ZIP with `ditto`, rechecked signature, then booted its actual executable with Metal on Apple M2 Pro. It initialized Steam, hosted the three-place waiting room and exited normally after the bounded startup check. No script errors. This is startup verification, not three-human Steam acceptance.
- Some local ENet fixture shutdowns retain the documented ObjectDB/resource warning. Windows execution, Intel Mac execution, ordinary/adverse cross-platform Steam play and human fun/accessibility remain playtest checks in ticket 06.

## Local playtest build identity

Both packages are explicitly marked `provisional_working_tree: true`, with exact source-file hashes; no commit or publication is fabricated. They contain the revised instructions and diagnostics launcher. No release was published.

Source manifest SHA-256: `5a2289862bcce2ef534fb6676f95f4957b1640f1e8eaf60a1a2ec79c517d5f7b`.

| ZIP | SHA-256 |
| --- | --- |
| licensed-scrapyard-windows-x86_64.zip | `89f5ba6377fe6152e98334f77069635b4f48360650091af757e097264fd99c91` |
| licensed-scrapyard-macos-universal.zip | `74a59660341b1154e527a16b09d6dea740fc975a8252beb35958a6bf9445c2fb` |

The archives and `SHA256.txt` are in `export/monster-truck-high-body-2026-09-14/`. Current GLB, learner and truck scripts were independently compared with the packaged source manifest. Documentation/evidence may be appended after packaging without changing the identified runtime snapshot. Mac signing is ad hoc and Windows is unsigned; packaged README gives platform launch instructions. All three testers must use the same source-manifest identity.

Tickets 29 and 32 are now complete for local playtest preparation. Ticket 06 remains unaccepted and gates further route work. Use the packaged `SESSION.md` for role rotations, active/idle balance comparison, a successful pass and recovery followed by pass.

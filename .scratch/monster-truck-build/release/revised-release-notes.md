Revised monster-truck playtest for exactly three friends on Steam. The previous scrapyard prerelease remains available.

## What changed

- A smaller, higher truck body with oversized wheels and an open cabin.
- Shared elevated camera so everyone can see the route.
- Hold Space while walking against the truck to climb; aim at a highlighted seat and press E to sit. E leaves the seat.
- Steering: A/D. Speed: W forward, S brake then reverse; release to slow. Balance: A/D sideways, W/S forward/back.
- Stop and press 1/2/3 to request a different responsibility; the other occupant accepts with Y or declines with N.
- A complete short test: turn, bumps, then parking, with shared instructions, a six-minute timer, a pass and a rating. Hold R when prompted to recover. Recovery and cone contacts lower the rating but still allow a pass.

## Download and play

Download the Windows x86_64 or macOS universal ZIP below and extract everything. Read README.md and SESSION.md inside. All three players need this same release and separate signed-in Steam accounts. This development build uses app 480 / Spacewar. Gather at reception, select the monster truck at the booking board, and sit in the waiting-room chairs.

Windows: launch licensed.exe or run-playtest.cmd. macOS: open licensed.app (macOS 11+ target, Apple silicon and Intel). Windows is unsigned; the Mac app is ad hoc signed, without Developer ID signing or notarization. If macOS blocks the download, follow the included README's per-app Open Anyway instructions.

## Verification and scope

Built from commit `8bafeb3ecdcb37b7b50f75a1dc238ad36e99a745` using Godot 4.7.2 and GodotSteam 4.22.1. Both manifests identify committed source and record packaged-file hashes. ZIP integrity, packaged-file hashes, Windows binary architecture, Mac universal architecture and strict deep signature checks passed; export logs contain no errors or warnings.

The extracted final Mac app launched on Apple silicon, initialized Steam and exited with code 0. Its bounded shutdown reported ObjectDB/resource cleanup diagnostics; startup completed without script errors. Automated checks exercised boarding, controls, recovery, course completion and shared results. Windows native execution, Intel Mac execution and the next three-human Steam playtest remain pending. This release does not establish human checkpoint acceptance. The longer route and durable personal licenses remain deferred.

Verify downloads against SHA256.txt:

```text
48e34874b8fbb06f5e1a36ee95602fa57e149ce2c2b28c4dd2ecb08ea633817b  licensed-scrapyard-macos-universal.zip
faaca61489051f2c3b8ae28b893e63aa6775f1d531fe1843dbbb3f8044d61594  licensed-scrapyard-windows-x86_64.zip
```

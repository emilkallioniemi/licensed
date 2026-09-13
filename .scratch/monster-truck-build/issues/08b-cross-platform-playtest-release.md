# 08b: Prepare Windows and macOS playtest exports

Status: done
Blocked by: 08a
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Prepare reproducible Windows/macOS export tooling and dependencies for the static scrapyard checkpoint. Ticket 08c builds the final release from this committed source and publishes it under the user’s existing authorization.

## Acceptance criteria

- [x] Produce reproducible Windows x86_64 and macOS bundles using matching Godot/GodotSteam runtime dependencies and the same committed game source; preserve Steam shipping transport and exactly-three-human rules.
- [x] Include concise platform launch instructions, build/asset hashes and honest signing/platform verification limits; verify archive integrity, dependency architecture/linkage and Mac exported-app launch where available.
- [x] Complete appropriate export/regression checks and reviews; retain source/evidence. Existing Windows-only and modeled-only ZIPs remain historical.
- [x] Prepare accurate release/launch notes and a commit-based build procedure for 08c; verify both exports before root commits. No full-course or human acceptance claim.

## Comments

- 2026-09-13: User requested Windows and Mac bundles and a GitHub release so friends can test. Publishing was paused only to add approved static scrapyard 08a; resume after it passes.
- Repository: `emilkallioniemi/licensed`; existing public release `waiting-room-playtest`. Use a new release/tag; do not replace historical assets.

- Release provenance: 08b commits verified export tooling/dependencies; 08c builds from that exact commit, publishes the tag/assets, then records publication evidence separately so the tag identifies the game source.

- Fixed ticket base: `e57e8a2ff53b573cee412abfe5c6e67089c77338`. Static scenery08a complete; prepare verified export tooling and provisional bundles, leave all source uncommitted for root.08c performs final exports from the resulting exact commit and publishes.

- 2026-09-13: 08b tooling verified with native provisional dual-platform export 4; zero residual Standards/Spec findings. Source intentionally remains uncommitted for root; 08c rebuilds final bundles from that resulting commit. See [verification](../release/verification.md), [procedure](../release/README.md) and [draft release notes](../release/release-notes.md). Status remains claimed until root commits. Platform/human limits are explicit; no full-course acceptance claim.

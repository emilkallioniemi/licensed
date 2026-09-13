# 08c: Publish the cross-platform scrapyard playtest

Status: done
Blocked by: 08b
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Build final Windows/macOS archives from the committed 08b source and publish them as a new GitHub playtest release in emilkallioniemi/licensed. The user explicitly authorized publishing after the static scenery pass.

## Acceptance criteria

- [x] Export both platform archives from the exact 08b commit; record commit/tree, dependency/template and archive hashes, and verify archive contents and Mac launch.
- [x] Publish a new playtest tag/release pointing at that source commit with both archives, checksums and clear launch instructions, including same-version requirement and accurate signing/platform limitations.
- [x] Verify the remote release and uploaded asset hashes; return the release link. Record publication evidence without moving the source tag or claiming human checkpoint acceptance.

## Comments

- 2026-09-13: Split final publication from export-tooling commit to keep the tagged game source reproducible. User approval already covers both platform bundles and publishing; no further routine confirmation is needed.

- Fixed ticket base and release source: `728ae10d8624d03f1f256aa47c1183aefa8582df`. Root verified08b clean and one commit; final archives must use this exact source.

- 2026-09-13: Final committed exports and extracted Apple silicon startup verified; published [scrapyard-playtest-2026-09-13](https://github.com/emilkallioniemi/licensed/releases/tag/scrapyard-playtest-2026-09-13) on the fixed source commit. Both ZIPs and SHA256.txt were downloaded from the public prerelease and matched locally. Full hashes/provenance, launch facts and explicit human-check limits are recorded in [release verification](../release/verification.md). Standards and spec review: zero source findings. Evidence is committed separately without moving the source tag.

# 08c: Publish the cross-platform scrapyard playtest

Status: ready-for-agent
Blocked by: 08b
Parent: [A complete monster truck vehicle](../../monster-truck/spec.md)

## What to build

Build final Windows/macOS archives from the committed 08b source and publish them as a new GitHub playtest release in emilkallioniemi/licensed. The user explicitly authorized publishing after the static scenery pass.

## Acceptance criteria

- [ ] Export both platform archives from the exact 08b commit; record commit/tree, dependency/template and archive hashes, and verify archive contents and Mac launch.
- [ ] Publish a new playtest tag/release pointing at that source commit with both archives, checksums and clear launch instructions, including same-version requirement and accurate signing/platform limitations.
- [ ] Verify the remote release and uploaded asset hashes; return the release link. Record publication evidence without moving the source tag or claiming human checkpoint acceptance.

## Comments

- 2026-09-13: Split final publication from export-tooling commit to keep the tagged game source reproducible. User approval already covers both platform bundles and publishing; no further routine confirmation is needed.

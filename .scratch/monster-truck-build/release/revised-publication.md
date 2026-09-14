# Revised monster-truck prerelease publication

Published 2026-09-14: https://github.com/emilkallioniemi/licensed/releases/tag/monster-truck-playtest-2026-09-14

Tag: `monster-truck-playtest-2026-09-14`, source commit: `8bafeb3ecdcb37b7b50f75a1dc238ad36e99a745`. Built with the pinned release builder in committed-source mode into `export/monster-truck-playtest-2026-09-14`. Both manifests identify this commit and set provisional_working_tree to false. Earlier releases remain unchanged.

GitHub API confirmed prerelease=true, draft=false, all three assets uploaded. GitHub SHA256 digests match both local ZIP hashes and SHA256.txt. Archive CRC and packaged-file hashes, Windows x86_64 headers, Mac universal architectures and strict deep signature passed. Export logs have no errors or warnings.

The final Mac ZIP was extracted with ditto and its strict deep signature verified again. The extracted app started on Apple M2 Pro, initialized Steam and hosted reception; bounded launch exited 0. Shutdown reported two ObjectDB instances and one resource still in use; no script errors. This is startup evidence, not human playtest acceptance. Windows/Intel native execution and the next three-human Steam playtest remain pending.

Published ZIP hashes:

```text
48e34874b8fbb06f5e1a36ee95602fa57e149ce2c2b28c4dd2ecb08ea633817b  licensed-scrapyard-macos-universal.zip
faaca61489051f2c3b8ae28b893e63aa6775f1d531fe1843dbbb3f8044d61594  licensed-scrapyard-windows-x86_64.zip
```

Release notes: [revised-release-notes.md](revised-release-notes.md). Prior working-tree ZIPs documented in art-verification.md are superseded for distribution by this committed prerelease.

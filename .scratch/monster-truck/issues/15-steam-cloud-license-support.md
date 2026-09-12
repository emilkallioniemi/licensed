# What Steam Cloud setup and reconciliation support personal licenses?

Label: wayfinder:research
Type: research
Status: resolved
Parent: ../map.md
Blocked by: 14

## Question

Using official Steamworks and GodotSteam sources and the installed integration, determine the supported implementation path for the local saves and Steam Cloud backup agreed in [How are personal licenses saved and test transitions kept consistent?](14-trio-license-and-transition-consistency.md). Personal ownership and backup intent are settled; investigate the facts needed for a buildable specification.

Compare Auto-Cloud and explicit Remote Storage for account-scoped files, preserving earned stamps and best ratings when older local or cloud copies exist. Establish which conflicts the game can merge and which happen outside the game; distinguish offline local saving, confirmed local durability, upload, and restoration on another computer. Do not promise recovery from overwritten or lost copies that are no longer available.

Identify APIs available in this project's GodotSteam version, required Steamworks configuration and access, and what can be tested with development app ID 480 versus an owned app ID. Give a concrete validation procedure for account separation, interrupted upload, stale copies, reinstallations, and switching computers. Identify any human-only configuration dependency precisely; do not provision or change external configuration during this investigation.

Capture findings with primary-source links and recommend the implementation path and remaining dependency checks. This ticket researches Cloud support, not a new progression design or broader Steam release operations.

## Answer

Resolved by primary-source and local-integration research on 2026-09-12. [Steam Cloud support for personal licenses](../research/steam-cloud-license-support.md) holds the cited findings, version-specific API table, configuration handoff, and validation procedure.

- Recommend explicit RemoteStorage backup alongside an independent Steam-account-scoped local license and receipt store excluded from synchronization. Merge available valid copies by stamp union and best rating, commit locally, then stage the merged backup. Keep development records separate.
- Start with bounded synchronous reads/writes and measure staging latency. The advertised GodotSteam 4.22.1 source supports the needed APIs; its asynchronous wrappers return no operation handle and have callback-correlation limitations documented in the research. Runtime verification remains an implementation check.
- Steam may resolve conflicts before launch. Reconciliation preserves progress from surviving accessible copies, including independent local records and valid receipts; it cannot recover overwritten or lost copies that no longer exist. Local commit, Steam-managed write, upload, and restoration on another computer are distinct outcomes.
- An authorized partner must configure and publish Cloud quotas for an owned app ID and grant test-account access. App 480 supports development investigation but does not validate the owned app's configuration. The research records the exact handoff and account-separation, stale-copy, interrupted-upload, and clean-restoration checks.

This resolves the capability investigation and recommended implementation path. Configuration, bounded storage/quota sizing, runtime verification, and multi-computer tests belong in the subsequent specification and implementation; none was performed here. No progression decision was reopened, and no new planning blocker was identified.

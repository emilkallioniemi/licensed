# Steam Cloud support for personal licenses

Investigated 2026-09-12 for [What Steam Cloud setup and reconciliation support personal licenses?](../issues/15-steam-cloud-license-support.md). Research only: no game implementation, Cloud writes, partner configuration, or multi-computer tests were performed.

## Recommendation

Use explicit `ISteamRemoteStorage` through GodotSteam for a Cloud backup, alongside an independent, account-scoped local license and result-receipt store. Exclude that independent store from Auto-Cloud. At load, reconcile the available local record, the Steam-managed copy, and valid surviving receipts; retain the union of earned stamps and the better rating for each vehicle. Commit the merged record locally before staging it back through RemoteStorage. Never initialize Cloud with an empty record before checking existing data.

This is an engineering recommendation implementing [How are personal licenses saved and test transitions kept consistent?](../issues/14-trio-license-and-transition-consistency.md), not an additional progression decision. A single bounded Cloud snapshot is a reasonable first implementation; do not add an unbounded per-attempt Cloud file archive. Receipt retention and snapshot size limits need specification and quota budgeting. Multiple retained generations can improve recovery only while those generations actually survive.

The crucial separation is **independent local storage versus Steam-managed storage**, not merely two differently named files in the same synchronized directory. Steam can replace its own local copy before the game launches. A separate local record gives the game something to merge with afterward on that computer. On a clean computer, only the copies actually downloaded or otherwise recovered are available.

## Evidence and current integration

The installed [extension manifest](../../../addons/godotsteam/godotsteam.gdextension) identifies GodotSteam GDExtension 4.22.1, release tag `v4.22.1-gde`, Steamworks SDK 1.65, and Windows x86_64 libraries only. The [bundled readme](../../../addons/godotsteam/readme.md) agrees. [SteamClient](../../../scripts/steam_client.gd) initializes app 480 using `Steam.steamInitEx(APP_ID, true)` and obtains an integer Steam ID. [ADR 0002](../../../docs/adr/0002-steam-only-networking.md) establishes Steam as the shipping transport and app 480 during development. There is no implemented personal-license persistence in the inspected scripts/tests; `user://voice.cfg` is unrelated settings storage.

The version-specific bindings below were checked against the official [4.22.1 GDExtension implementation](https://codeberg.org/godotsteam/godotsteam/src/tag/v4.22.1-gde/godotsteam.cpp) and [header](https://codeberg.org/godotsteam/godotsteam/src/tag/v4.22.1-gde/godotsteam.h). This confirms the advertised release's source, not the loaded DLL's runtime reflection or successful Cloud operation. A runtime binding check remains part of implementation validation. GodotSteam's documentation website could not be fetched during this investigation; versioned first-party source was available instead.

## Auto-Cloud versus RemoteStorage

Valve supports file-pattern Auto-Cloud and API-managed storage. Both normally synchronize around game sessions. RemoteStorage isolates users and permits explicit file handling. Auto-Cloud supports `{64BitSteamID}` and `{Steam3AccountID}` in paths but requires correct path configuration. [Steam Cloud overview](https://partner.steamgames.com/doc/features/cloud)

| Concern | Auto-Cloud | Explicit RemoteStorage |
| --- | --- | --- |
| Local gameplay independence | Ordinary local writes are straightforward. | Keep ordinary local writes independent of the API. |
| Account separation | Configure the account token and write to the matching directory. Broad recursive patterns risk capturing other accounts. | Steam isolates API files; additionally validate the owner inside the payload and isolate the game's local records. |
| Merge opportunity | The synchronized local file may already have been replaced at launch. Requires a separate excluded copy to compare. | Read the Steam-managed snapshot separately from the independent record, then merge. |
| Application control | File-pattern configuration chooses what Steam manages. | Explicit read/write results, file checks, quota handling, and retry policy fit the needed backup adapter. |
| Main cost | Less API code, more path-sensitive configuration; still needs application reconciliation. | More adapter code and wrapper-specific asynchronous handling. |

The table's fit assessment is our inference from those mechanisms and the agreed monotonic ownership requirement. Neither method grants the game a server-side merge transaction or access to every historical version.

For a hypothetical Auto-Cloud alternative, sync a dedicated export copy only, with an account-token subdirectory and a narrow pattern. Do not synchronize the independent local record, temporary files, unrelated voice settings, development fixtures, or every account beneath one common root. For the recommended API path, no Auto-Cloud rule should overlap the independent store or API-managed files.

## Merge and durability contract to specify

These are proposed implementation rules derived from the personal-license consistency decision:

1. Identify storage by the signed-in Steam account, storing the full Steam ID as decimal text in serialized data to avoid JSON-number precision loss. Put app 480, owned-app data, and development transport fixtures in distinct namespaces. Missing Steam identity must never fall back to another account's last-used record. Local saving without Cloud connectivity does not imply the current game supports launching without a Steam client.
2. Decode and validate each available copy before merging: schema version, owner, known vehicles, allowed ratings, attempt identity, participant identities, and settled-result receipt contents. Unsupported schema, malformed data, and read failure are different from a genuinely absent file. Preserve unreadable copies for diagnosis; avoid replacing them with a blank license.
3. Use stamp set union and an explicit rating-quality comparator, not modification time. A numerically larger value is not automatically a better rating. Receipts may restore only awards from their named settled attempt for the receiving participant; sharing a room transfers no unrelated achievements. Duplicate receipts have no effect.
4. Commit the settled result and receipts locally at test completion. A local-save acknowledgement means a validated local commit succeeded, not simply that serialization began. Specify a recoverable write protocol, such as a validated temporary file plus retained previous generation and checked replacement. Test process termination at its intermediate steps. Do not describe application-level file success as an unconditional power-loss guarantee.
5. Start backup independently after the local merge/commit. Track the generation being staged; if the license improves during a pending write, retain a dirty newer generation. A late completion must not mark newer data backed up. Local failure must remain visible and recoverable without trapping the group, per the personal-license consistency decision.
6. Read/merge before overwriting the Steam snapshot on each launch. Never interpret Cloud disabled, timeout, quota exhaustion, or corrupt content as evidence that the account has no earned stamps. Keep local progression usable and retry staging later.

Steam's asynchronous write completion explicitly reports success of the **local** write. `filePersisted` describes Cloud persistence but does not expose an acknowledgement tied to our particular generation; neither it nor a callback should be presented as proof the latest bytes reached another computer. Batch calls are synchronization hints, not transactions. [RemoteStorage API](https://partner.steamgames.com/doc/api/ISteamRemoteStorage#RemoteStorageFileWriteAsyncComplete_t)

Use distinct internal states: result settled in memory; local commit confirmed; Steam-managed write confirmed; remote synchronization observed in Steam; matching data restored on another computer. Only the last check demonstrates that tested generation's restoration. No game-facing wording is designed by this research.

## Conflicts the game cannot intercept

Steam can ask the player to choose a local or Cloud copy at launch when both changed without synchronization. Offline play can create such divergence; ignored synchronization errors can lose progress. Steam Support does not recover lost saves. [Valve's Cloud support guidance](https://help.steampowered.com/en/faqs/view/68D2-35AB-09A9-7678)

Consequently, “merge local and Cloud” must mean merging **copies accessible to the game**, not both sides of Steam's earlier conflict prompt. RemoteStorage is a Steam-managed local/cache interface; an API read is not an on-demand server-history query. If the prompt discarded a better Steam copy, an independent record on that machine or a surviving participant receipt may still repair it. If the better version exists only on another offline computer, that computer must return or contribute a surviving copy before recovery is possible. If all better copies were overwritten, deleted, or never durably saved, monotonic reconciliation cannot reconstruct them.

Do not enable Dynamic Cloud Sync as a configuration-only shortcut. If enabled later, handle `local_file_changed`, enumerate changed files, validate and merge them with independent state before further writes, including deletion notifications. The documented event occurs after Steam changes local files. For this Windows-only implementation, recommend leaving that optional feature disabled until its resume/change path has its own validation. [Dynamic-change API contract](https://partner.steamgames.com/doc/api/ISteamRemoteStorage#GetLocalFileChange)

## Exact GodotSteam surface

Names and return shapes below are from the linked versioned source, not translated mechanically from Valve's C++ signatures.

| GDScript-facing method or signal | Return/data shape and intended use |
| --- | --- |
| `isCloudEnabledForAccount()`, `isCloudEnabledForApp()` | `bool`; inspect both. Do not silently enable a disabled preference. |
| `getQuota()` | Dictionary with `total_bytes`, `available_bytes`; an uninitialized interface can return an empty dictionary. |
| `fileExists(file)` | `bool`; establish absence separately from decode failure. |
| `getFileSize(file)`, `getFileTimestamp(file)` | Integers; use a bounded size for reading. Timestamp is diagnostic, not merge authority. |
| `getFileCount()`, `getFileNameAndSize(index)` | Count and dictionary enumeration; only process this game's intended filenames, especially under 480. |
| `fileRead(file, data_to_read)` | Dictionary: `ret` is the read byte count on a successful interface call, `buf` is `PackedByteArray`; early interface failure initializes `ret` to false. Check exact byte count before decoding. |
| `fileWrite(file, data, size = 0)` | `bool`; zero means use the array length. Never pass a size larger than the provided byte array. |
| `fileReadAsync(file, offset, data_to_read)` | **Returns void**, unlike Valve's call-handle return. |
| `file_read_async_complete(file_read)` | One dictionary: `result`, `handle`, `buffer`, `offset`, `read`, `complete`. Require `result == Steam.RESULT_OK`, `complete`, and expected read size. The wrapper already invokes native `FileReadAsyncComplete`; the game does not invoke that native step separately. |
| `fileWriteAsync(file, data, size = 0)` | **Returns void**. No exposed immediate accepted/invalid handle result. |
| `file_write_async_complete(result)` | One integer result; no filename, generation, or handle. |
| `filePersisted(file)` | `bool`; useful diagnostic, not latest-generation upload proof. |
| `beginFileWriteBatch()`, `endFileWriteBatch()` | `bool`; paired hints if several Steam-managed changes represent one state change. |
| `getSyncPlatforms(file)`, `setSyncPlatforms(file, platform)` | Bitfield query and boolean setter. No current need for cross-platform overrides in the Windows-only project. |
| `local_file_changed()` | No arguments. |
| `getLocalFileChangeCount()`, `getLocalFileChange(index)` | Count and dictionary with `file`, `change_type`, `path_type`. Relevant to optional Dynamic Cloud Sync. |

The source has one `callResultFileReadAsyncComplete` and one `callResultFileWriteAsyncComplete` registration slot. Starting another operation of the same kind resets that slot. Both completion handlers return early on `io_failure` without emitting their normal signal. Invalid native call handles are not surfaced by the void wrappers. These facts require a **single serialized operation owner**, validation before dispatch, bounded waiting, and a failure/retry state rather than indefinite awaiting. After a timeout, do not immediately issue an indistinguishable same-kind write and allow an old callback to acknowledge it; quarantine the operation until resolved, defer to a later session, or choose the synchronous adapter instead. [GodotSteam 4.22.1 implementation](https://codeberg.org/godotsteam/godotsteam/src/tag/v4.22.1-gde/godotsteam.cpp)

Recommend synchronous `fileRead`/`fileWrite` for the first bounded license-snapshot adapter because its immediate result is unambiguous and avoids the installed wrapper's asynchronous correlation gap. Put backup staging after the independent local commit, keep payload size bounded, and measure disk latency in the acceptance build. If measured stalls are unacceptable, the async queue/lifecycle work above becomes an explicit replacement requirement before switching. This is a concrete initial API path, not an unmeasured performance guarantee.

## Human configuration dependency

An owned application ID and an authorized Steamworks partner account are required to configure this game's production Cloud. The responsible person must have access to the app and the `Edit App Metadata` and `Publish App Changes To Steam` capabilities, or obtain them from a partner administrator. Publishing technical app settings is a distinct permission. [Valve account permissions](https://partner.steamgames.com/doc/gettingstarted/managing_users)

Concrete handoff:

1. Confirm the owned app ID and who can edit/publish its Steamworks settings. Record the app ID and permissions outcome, never credentials, in the implementation dependency.
2. In that app's Steam Cloud settings, set nonzero per-user byte and file quotas, then Save and Publish. Size the quota from the chosen bounded snapshot/receipt representation plus replacement headroom. Do not invent final quotas before that size bound exists.
3. Keep Auto-Cloud paths absent for this API design, shared-cloud app ID unset/zero unless separately designed, and Dynamic Cloud Sync disabled initially. Confirm no existing rule covers the independent local record.
4. Ensure test accounts own the app; use Developer Comp access where applicable. If developer-only Cloud is selected for an already public app, eligible testing accounts need Developer Comp licenses. Wait for the published configuration to reach clients, restarting Steam if necessary.
5. Provide the configured app ID, quota values, published-state evidence, and test-account access confirmation so the implementation can run the owned-app validation below.

Quota setup and developer-only behavior are documented by [Valve's initial Cloud setup](https://partner.steamgames.com/doc/features/cloud#initial_setup). None of these external prerequisites was verified or changed here. This is a precise human handoff, not a request to provision unrelated release infrastructure.

## App 480 boundary

App 480 is Valve's Spacewar development app, already selected by this repository. It is useful for binding checks, initialization, test-file read/write handling, and exploratory synchronization if the current account/client allows it. The official API documentation uses 480 for development initialization. [Steamworks API overview](https://partner.steamgames.com/doc/sdk/api#SteamAPI_Init)

Inference: because Cloud belongs to an app/account context, 480 is shared development infrastructure, not a private licensed production namespace. Use unique `licensed` test filenames and only touch files created for this test; do not enumerate-and-delete arbitrary 480 data. Do not claim its live quotas or Cloud settings were checked here. Success under 480 cannot establish our owned app's configuration, ownership access, distribution flow, or isolation from other 480 experiments. Development fixtures must not silently migrate into an owned-app license.

## Validation matrix

Implement these cases after the adapter exists. Record app ID, build, account identities, machine labels, input snapshots, expected stamps/ratings, write outcomes, and restored payload generation/hash. Use synthetic test data and preserve originals before deliberately exercising loss scenarios. Windows x86_64 is the current scope.

| Case | Procedure | Required observation |
| --- | --- | --- |
| Runtime bindings | Reflect installed singleton methods/signals and inspect argument/return types without writing Cloud. | Matches the table; failures are reported before persistence is enabled. |
| Local independence | Disable Cloud or disconnect networking after identifying the account; settle and save a result, restart. | Own stamp/best rating retained locally; no false upload confirmation. Existing Steam-client launch requirements remain respected. |
| Accounts on one computer | Save distinct licenses under A and B in the same OS account, switching Steam accounts between launches; return to A. | Separate local paths and API copies; mismatched payload owner rejected; A unchanged by B. |
| Development isolation | Run ENet fixtures and app480 test records, then the owned-app build. | No automatic fixture/test award import. |
| Stale local | Prepare weaker local data and stronger Steam snapshot for the same owner; launch. | Union/best persisted locally and staged to Steam. |
| Stale Steam copy | Keep stronger independent local data; deliver a weaker Steam snapshot. | Better local data survives and repairs the backup. |
| Disjoint offline computers | On A earn one stamp offline; on B earn another offline; reconnect sequentially and revisit each. | Document Steam's prompt if any; union occurs when surviving independent copies become available, not before. |
| Prelaunch conflict | With preserved test originals, exercise each choice in Steam's conflict prompt. | Game reports only accessible data; independent local record survives either choice on that machine. |
| Interrupted staging/upload | Stop after local commit but before API completion, then separately stop/network-disconnect after API completion but before Steam sync; restart original PC and inspect clean second PC. | Original local result survives; second PC gets only actually synchronized data; later successful sync restores it. |
| Async edge cases | If async chosen, simulate missing callback, I/O failure, invalid request, late callback, and a better result arriving while a write is pending. | No hang, wrong-generation acknowledgement, or overwritten call-result registration. |
| Write/quota failure | Inject local write failure; separately reject Steam write or exhaust an isolated test quota. | Memory/receipt recovery remains possible; local and Steam failures distinguished; no destructive clearing. |
| Corrupt/unknown schema | Supply truncated bytes, malformed owner, unsupported version, invalid rating. | Reject or quarantine, retain valid surviving data, no blank overwrite. |
| Clean restoration | Finish sync on A, confirm Steam state and logs, install/run on clean B without independent data for that test. | Exact expected account license restored, then saved independently on B. |
| Reinstallation | Test reinstall with local data retained, then separately a genuinely clean profile/installation with local data absent. | The first proves local continuity; only the second after sync proves Cloud restoration. Uninstall alone is not proof local data vanished. |
| Receipt recovery | Lose one participant's record and restore from one surviving original friend's receipt; replay twice and present unrelated receipts. | Only named settled awards restored; duplicates idempotent; unrelated awards rejected. |
| No surviving copy | Remove all synthetic local, Steam, and receipt copies for an award. | No invented restoration or promise of recovery. |

For real transfer cases, exit the game on A, wait for Steam synchronization, inspect `logs/cloud_log.txt`, then launch on B and compare the payload. Return to A to verify convergence. Repeat using the **owned app** with actual distinct Steam accounts for account separation; local transport fixtures do not validate Steam ownership or Cloud setup. Valve identifies `cloud_log.txt` in its [Cloud troubleshooting guidance](https://help.steampowered.com/en/faqs/view/68D2-35AB-09A9-7678).

Research is sufficient to recommend a buildable adapter and explicit dependency. Outstanding evidence is runtime binding verification, bounded representation/quota choice, owned-app configuration and access, and execution of the matrix. Nothing here establishes that the latest earned result is already backed up.

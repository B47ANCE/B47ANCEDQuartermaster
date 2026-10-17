# Workshop MP test distribution — 0.16.0-dev.2

Prepared on 2026-10-16 (America/Phoenix) under the explicit publish request. **Status: PUBLISHED as an MP testing build; public metadata and Steam restart verified.** Workshop update time: 2026-10-16T02:20:01-07:00 (America/Phoenix).

- Existing Workshop item: `3807217050`; App ID `108600`; Mod ID `B47ANCEDQuartermaster`.
- Existing title/public visibility verified through Steam's published-file API; linked Rooms, Auto Clean and Extended Categories items resolve successfully. Existing artwork is retained byte-for-byte.
- Runtime implementation commit: `81c36bb1f8475c6ce02372810f599155b5e838e4`. This preparation changes description/notes/docs only; the package is checked against all current runtime source bytes again before upload. The final release commit is recorded in the upload manifest/receipt.
- Package: `dist/current/B47ANCEDQuartermaster-0.16.0-dev.2.zip`, **209 runtime files**, SHA-256 `27eed2e7d5142c669d4b51f70d6d82cbec303189812c557bc7e0953767715ddf`.
- Canonical Workshop inputs: root `WORKSHOP_DESCRIPTION.txt`, `WORKSHOP_CHANGE_NOTE.txt`, `WORKSHOP_ID.txt`, existing custom `preview-client.png`, and canonical `VERSION`/runtime metadata.
- Generated staging: `C:/Users/willi/Zomboid/Workshop/B47ANCEDQuartermaster`, copied from the new version-specific build stage and verified exactly; maximum runtime path 156 characters. Previous packages/provenance were not moved/deleted. Local live mods/server files were not changed.
- Ignored release records: `dist/workshop-publish/0.16.0-dev.2/` contains the pre-upload public metadata snapshot, build/paired-test logs, VDF, payload hashes and release manifest. They are not public source inputs or runtime components.

## Validation

[TESTED OFFLINE] `Build-Workshop.ps1` completed full Lua 5.1/regression and native-category checks, packaging, parity rejection tests, source/package/staging byte equality and `scripts/check_versions.py --release`. ZIP CRC, unique/case-safe member paths, traversal refusal, Lua-only payload, native artwork bytes and VDF/newline/ID/public-visibility checks pass. The 320,808-byte preview is unchanged. Source manifest: 209 files.

The default build-runner sibling Rooms path is absent in this isolated worktree. A separate execution of production `tests/test_rooms_integration.lua` with the actual `B47ANCEDRooms/src/B47ANCEDRooms/42/media/lua` path passes descriptor/privacy, discovery, deposit/configure/withdraw separation, live revocation, service mismatch and historical disclosure fixtures. This is offline integration evidence, not dedicated MP.

Commands:

```powershell
$env:PYTHONUTF8='1'
./Build-Workshop.ps1 -WorkshopRoot './dist/workshop-publish/0.16.0-dev.2/staging'
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' -B scripts/check_deployment.py --package --stage 'C:/Users/willi/Zomboid/Workshop/B47ANCEDQuartermaster'
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' -B scripts/check_versions.py --release
git -c core.safecrlf=false diff --check
```

Current jar SHA-256: `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`; target PZ 42.21.0, installed Steam build 25485521. Public GitHub origin is verified as B47ANCE/B47ANCEDQuartermaster. Feature tracking branch is current; the older default branch's one README-only divergence is reviewed, not presented as missing gameplay or a blanket freshness PASS.

## Distribution status and limits

**MP testing build - dedicated multiplayer NOT TESTED.** Full native client and dedicated acceptance for this candidate are pending. G7 remains BLOCKED / NOT TESTED; stable-release G8 remains BLOCKED. Upload is authorized test distribution under the current shared policy, not stable-release approval.

The description and changenote disclose default-on completed supply-ledger requirements, physical shopping paper/writing supplies, supported stock computer/storage-CD limits, matching-peer reconnect, no automatic vehicle sweeps, and unsupported fluid/partial cooking plans. Legacy personal shopping data is preserved for explicit import. Protocols: movement 10, Shopping 3, Personal 2, Ledger 2. Native transfer grouping remains unchanged.

After confirmed publication, verify subscription/download, server startup, two-client join/rejoin, paper trading/edits, ledger grants, transfer conservation, synchronization, persistence and restart. No game/server launch or remote deployment is authorized by this record. Steam desktop restart follows verified upload success only and is recorded separately.

## Confirmed publication receipt

- SteamCMD reported `Committing update...Success` and exited **0** for existing item `3807217050`.
- Release source commit: `65f10e0dbbe21f9de8c1e1326406e0289f7daf25`. Package SHA-256: `27eed2e7d5142c669d4b51f70d6d82cbec303189812c557bc7e0953767715ddf`. Runtime source/package/stage contain the same 209 files.
- Public Steam API result **1**; normalized canonical description matches exactly, update timestamp advanced, and title/public visibility/tags are unchanged. [Public Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=3807217050).
- The initial redirected-output startup stalled before any upload confirmation. Its owned helper was interrupted and confirmed exited before the successful terminal retry; no credentials were supplied in source/arguments beyond the cached account selection.
- Steam desktop exited gracefully and restarted from its verified executable. New client process confirmed; no forced termination or game/server launch. This is not proof that subscribed content downloaded or that MP works.
- Ignored `publication-receipt.json`, `steam-restart.json`, `release-manifest.json`, `payload-integrity.json`, public metadata snapshots and the existing package retain exact evidence. Release manifest SHA-256: `7326d1a17e350fb601bc86ab64573ebf547cb0bf04bfb26e85a77b7da8f56b51`.
- Native SP/dedicated acceptance remains NOT TESTED; G7/stable G8 remain blocked. Local live mods and the remote dedicated server were not modified.

# Audit remediation candidate

Project Version: 0.4.0-dev.47

Compatible PATCH iteration from dev.46. Runtime remains Lua-only. Category IDs,
configuration schema, additive presets and vanilla item-transfer authority are
unchanged. No deployment, package build, Workshop publication or game/server
launch is authorized by this correction pass.

| Audit finding | Disposition and evidence |
| --- | --- |
| One-item native Sort stop | OPEN / RUNTIME GATE. Historical dev.45 attempts cancel during PUT. No dev.46 Sort result is available in the current client/server copies. No speculative native behavior change is claimed as a fix. |
| Cancelled shopping TAKE remains busy | Known-unsubmitted and native-rejected cancellations relinquish the player's grant without moving or crediting items. Unknown submitted outcomes retain authoritative observation; they are not replayed or silently cleared. Offline cancellation/restart, malformed outcome and existing late-arrival tests pass. |
| Child category clear retains parent coverage | Clear names are collected before compatibility-family splitting, preserving untouched members. Offline parent-clear regression passes. Independent leaf-category rules retain their existing additive semantics. |
| Category/mod ranges affect hidden children | Range edits expand only into rendered item rows; direct category checkboxes retain whole-category behavior. Offline collapsed, item-filtered, forward/reverse and target-state tests pass. |
| Missing empty runtime directories in Git | A bounded helper recreates four required directories from a verified mod root. Build and package entry points invoke it; cold-checkout/idempotence tests preserve existing files. No placeholder assets or custom Java are added. |
| Native transaction lifecycle missing from tests | Additional pipeline run executes installed vanilla constructor, start, update, validation and perform methods against a simulated transaction ledger. Submitted item lists are snapshotted, acknowledgements drive completion and replay/group mutation are checked. Engine/network leaves, sounds and animation remain simulated. |
| Hidden selected container after scope change | Session drops an out-of-view selection; UI clears/disables the editor. Staged records are retained for later explicit selection/save. Offline session and picker tests pass. |
| Renamed item row disagrees with script-name rule | Indexed instances reuse their script-name row instead of adding a false unchecked alias. Only Contents includes actual and script names. Existing explicit instance-name routing remains supported. Offline catalog/count/routing tests pass. |
| Inventory category order differs from labels | Native row comparator receives localized display labels; canonical identity remains separately in b47Category. Actual vanilla comparator tests cover label/ID order differences, selection and refresh. |
| Add Item title/footer text overlaps | Decorated picker uses one shell title painter and omits legacy footer text. Offline draw-call/layout assertions pass; native visual acceptance remains pending. |
| Preferences erased by reads | Future/invalid preference structures are preserved and reported as schema errors. Only absent preferences get defaults. Offline invalid/future-schema/default tests pass. |
| Broken encoded punctuation | Shopping em dashes corrected to UTF-8; no translation key or player-facing wording change. |
| Contradictory current README version | Current statement corrected and inventoried as an additional required version mirror. Historical sections retain their original versions. |

Cancellation ownership: clients submit cancellation intent for their own opaque
operation handle. The server validates the handle and outcome enum. Releasing a
grant never authorizes movement, edits shared items, grants collected credit or
replays a native transaction. Older/unspecified/unknown outcomes retain the
existing fail-closed late-arrival reconciliation. The new field is optional;
protocol/schema versions remain separate from this project iteration.

Validation commands (configured Python runtime, project root):

```text
python tests/run_tests.py
python tests/test_runtime_directories.py
python scripts/check_versions.py --root .
python scripts/check_deployment.py
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output <local-temp-report.json> --approved-changes docs/DEV41_APPROVED_TAXONOMY_CHANGES.json
```

[TESTED offline] Full suite, source manifest and current version checks pass.
Vanilla comparison remains 5,092 items with exactly 625 approved deviations.
The published dev.46 package is retained under dist/history/0.4.0-dev.46 with
unchanged SHA-256; no current dev.47 package is claimed. Local diagnostic logs
and test reports are not public repository content.

[UNKNOWN / RUNTIME GATE] Actual dev.46 native stop reason, engine cancellation,
dedicated transaction continuation, native visuals and concurrent-peer/restart
acceptance require runtime evidence. SFTP console listing still crashes; no new
server log was retrieved. G7 NOT TESTED/BLOCKED; stable-release G8 BLOCKED.

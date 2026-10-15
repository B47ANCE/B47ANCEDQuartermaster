# Workshop description update — 2026-10-15

The owner explicitly reported Quartermaster dedicated MP tests PASS, clarified
that this result applies to Quartermaster rather than Eyewear, and approved
stable player-facing presentation. Record this as user-reported dedicated runtime
acceptance, not an agent-observed test or proof of every unlisted scenario.
Earlier offline/upload-time NOT TESTED records retain their original context.

## Scope and identity

Update the existing public Quartermaster item 3807217050 (App 108600), using
canonical WORKSHOP_DESCRIPTION.txt. Replace development warnings, test histories
and implementation details with sorting, Shopping, Dibs!, Rooms and window
features, followed by a short compatibility section. Required Rooms and optional
Auto Clean links retain their verified existing identities. The source repository
is public B47ANCE/B47ANCEDQuartermaster.

This is a description-only update to the existing tested payload, not a new
runtime iteration or package. Canonical runtime VERSION remains 0.11.0-dev.1;
the native metadata, Lua, protocols, schemas and archive bytes remain unchanged.
No package is renamed, regenerated or tagged as a different SemVer release.
Published runtime ZIP SHA-256:
23a9e39db322a608196d7642470a2e127b36ced43bfd8c5807931d9c90170557.

## Submission and version governance

Public prose intentionally omits a version line. Remove only that obsolete
description selector from version-inventory.json; all actual current version
mirrors and packaged metadata remain checked. Prepare-WorkshopVdf.ps1 now binds
source Mod ID/version to canonical identity instead of requiring technical version
text in the description. Existing full submissions still validate the current
changenote. Both render paths preserve Windows SteamCMD's required UTF-8 BOM.

The DescriptionOnly switch emits exactly appid, publishedfileid and description.
No contentfolder, previewfile, title, visibility, tags or changenote is submitted.
Valve's Steamworks implementation guide, SteamCmd Integration, documents that
existing-item updates set appid/publishedfileid and include only keys to change:
https://partner.steamgames.com/doc/features/workshop/implementation#SteamCmd

## Validation and evidence

Run from the repository root with the verified host Python/PowerShell:

```powershell
python -B scripts/check_versions.py --release
python -B scripts/check_deployment.py --package
pwsh -NoProfile -ExecutionPolicy Bypass -File ./Prepare-WorkshopVdf.ps1 -DescriptionOnly -OutputPath <fresh-description-vdf>
pwsh -NoProfile -ExecutionPolicy Bypass -File ./Prepare-WorkshopVdf.ps1 -OutputPath <fresh-full-render-check-vdf>
git diff --check
```

[TESTED: offline] Release version checks and source/package parity pass for 131
runtime files. ZIP CRC/hash, exact VDF field sets, source identity, full renderer,
Unicode/BOM, real paragraphs, balanced BBCode, byte limit and canonical text
round-trip pass. The default full-content staging directory is absent; that
unused path is not a valid full-content deployment target. This metadata-only
submission does not stage or upload content. No live deployment or server write.

The ignored dist/workshop-publish/description-2026-10-15 directory retains the
before snapshot, actual upload/verification receipt and fresh VDFs. The final
receipt binds the description/helper commit, unchanged runtime package hash,
SteamCMD result, exact live API comparison, retained content/artwork/visibility
and graceful Steam restart outcome. Historical package/provenance and previous
upload text are preserved. No new SP, detailed test-case or game-build evidence
is inferred from the owner's general dedicated MP report.

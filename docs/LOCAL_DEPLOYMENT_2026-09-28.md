# Local deployment — 2026-09-28

ProjectVersion: 0.2.0-dev.1

[TESTED offline] Command: `& '.\Quartermaster - Balanced Sorting\Build-Workshop.ps1'` (runs Build.ps1, version checker before/after, tests/run_tests.py --package, and check_versions.py --release). All checks passed. Version --release checks do not establish G8 readiness.

[VERIFIED] 70 runtime files matched SHA-256 from source in both C:\Users\willi\Zomboid\mods\QuartermasterSorting and C:\Users\willi\Zomboid\Workshop\QuartermasterSorting\Contents\mods\QuartermasterSorting. Verification used Get-ChildItem -Recurse -File and Get-FileHash -LiteralPath on every relative path, with exact file-count checks.

[VERIFIED source inspection] Installed SteamWorkshopItem.getPreviewImage requires preview.png; validatePreviewImage requires square 256/512 dimensions and at most 1024000 bytes. Build-Workshop.ps1 now stages preview-client.png as preview.png. The 512x512 PNG is 444667 bytes; full-size runtime poster is unchanged.

[VERIFIED] Workshop metadata retains item 3807217050. Old-ID client and Workshop directories moved into dist/deployment-backup-20260928-004231 (old-client and old-workshop). No automatic publishing or game launch performed.

[RUNTIME GATE] Enable QuartermasterSorting and dependency Quartermaster for testing. Native client (G6) and dedicated multiplayer (G7) untested; G8 blocked pending required evidence. Staging is prepared for requested manual publishing, not evidence of release readiness.
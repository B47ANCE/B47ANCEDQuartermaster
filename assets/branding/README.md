# Quartermaster artwork

Approved by the owner on 2026-10-15. The design uses one wooden storage crate and a small supply checklist to represent storage organization and supply planning.

## Originals and provenance

- `quartermaster-thumbnail-master.png`: exact approved 1254 × 1254 RGB thumbnail.
- `quartermaster-icon-master.png`: exact approved 1254 × 1254 RGBA icon with real alpha transparency.
- Created with the built-in OpenAI imagegen tool for this project. The icon uses the approved thumbnail as its design reference. The prompts below are retained so future artwork changes can be deliberate.
- Original generated artwork; no third-party mod textures, logos or code were copied. Vanilla inventory conventions informed the restrained isometric presentation.
- Original masters are authoring assets, outside the packaged `src/` tree. They are not layered/vector source files.
- Prior artwork remains recoverable from Git history. Previously published packages and release receipts were not modified.

## Export mapping

| Consumer | File | Size / format |
| --- | --- | --- |
| Full-resolution thumbnail | `preview.png` | 1254 × 1254 RGB PNG; exact thumbnail master bytes |
| Workshop staging thumbnail | `preview-client.png` | 512 × 512 RGB PNG |
| Existing JPEG mirror | `preview.jpg` | 1254 × 1254 JPEG, quality 95 |
| Native mod poster | `src/B47ANCEDQuartermaster/42/poster.png` | 1254 × 1254 RGB PNG; exact thumbnail master bytes |
| Native mod icon | `src/B47ANCEDQuartermaster/42/icon.png` | 256 × 256 RGBA PNG; transparent background |

Paths in this table are repository-relative. Run from the repository root:

```powershell
./scripts/Export-Artwork.ps1
python -B scripts/check_versions.py
python -B scripts/check_deployment.py
git diff --check
```

The host-only PowerShell exporter performs deterministic nearest-neighbor size/format conversion of the approved masters. It does not redraw the images, package the mod, update an installed copy, or upload anything. Existing `Build-Workshop.ps1` already consumes `preview-client.png`; native `mod.info` already references `poster.png` and `icon.png`. No consumer paths or Mod/Workshop IDs changed.

## Scope and version decision

This is a presentation-only artwork follow-up within the current `0.11.0-dev.1` source checkpoint, with no compatibility, gameplay, API, configuration or save changes. Canonical project version and its mirrors remain unchanged; no new release is claimed. A later authorized packaging/release must account for the changed source artwork instead of treating the prior package hash as current source parity.

The active source branch was equal to its upstream at `398ce01`. The default branch's one additional commit was the README-only refresh (`0c343ed`), already reflected by identical README prose in the source branch. No missing gameplay change was identified. Unrelated local AGENTS/audit work was preserved.

## Validation

The owner approved both original concepts visually before these replacements. Exported thumbnail/icon previews were checked separately after conversion. PNG/JPEG decoding, exact sizes, alpha transparency, master-to-preview/poster hashes, source inventory and canonical-version checks are recorded in `validation.json`.

Only `42/icon.png` and `42/poster.png` differ inside the runtime source tree. Native PZ rendering and Workshop display have not been retested for these assets. G7 is N/A for this local-presentation-only difference; previous gameplay evidence retains its original scope. No game/server was launched, and no package, deployment or Workshop publication occurred.

## Thumbnail prompt

```text
Create ONE finished square Steam Workshop thumbnail concept for the Project Zomboid mod "B47ANCE'd Quartermaster". This is original artwork for review, not a mockup, contact sheet, or in-game screenshot.

Purpose: Quartermaster organizes items into configured containers and helps plan supplies. Convey orderly storage, with ONE strong symbol. The design must feel like deliberate restrained game art that belongs beside Project Zomboid's utilitarian inventory sprites.

Composition: flat very dark charcoal background (#151817), generous empty space. At the top, small warm off-white text exactly "B47ANCE'd", then larger bold condensed pixel lettering exactly "QUARTERMASTER". Both perfectly legible, clean alignment, no other wording. Typography occupies approximately the upper quarter. Below it, one large original isometric wooden storage crate, open at the top, with consistent simple geometry: square opening, two visible faces, sturdy chunky planks and one diagonal brace on each face. Crate centered with ample margin and occupies about 60% of the canvas height. Use a slightly elevated three-quarter view similar to an isometric inventory object, with the left face a little lighter than the right.

The small sorting motif: a tidy rectangular pale parchment inventory checklist card attached to the LEFT visible front face of the crate, at its upper center. Three short dark horizontal strokes and two small subdued olive-green square checkmarks. The card is flat against that face in the correct perspective. No legible words on the card. It must look purposeful and simple, not a complicated UI. Nothing floating. Crate empty inside; no miscellaneous props, no surrounding item collage, no weapons, no zombies, no arrows.

Style: authentic low-resolution pixel artwork, drawn on approximately a 256x256 design grid and enlarged with crisp nearest-neighbor pixel clusters. Deliberate hard stepped edges, coherent pixel lighting from upper left, limited 18–24 color palette, muted worn walnut wood, desaturated olive accents and ivory. Wood texture consists of a few carefully placed pixels and plank seams, not dense noise or endless scratches. Dark outline only where needed for silhouette. Simple grounded pixel shadow. Modest depth, no cinematic lighting, no photorealism, no plastic 3D look, no bloom or glow, no lens effects, no gradient background, no ornate borders, no fake trademark emblems. Prioritize strong readable silhouette at 128px. The overall impression is a clean handcrafted survival-game inventory graphic and quiet product cover.

Square 1024x1024 output, fully opaque.
```

## Icon prompt

Reference: `quartermaster-thumbnail-master.png` (approved design reference).

```text
Create ONE matching transparent-background mod icon from the supplied Quartermaster thumbnail. The supplied image is the design reference: preserve its original isometric open wooden crate, camera angle, muted walnut palette, ivory checklist pinned to the left front face, two olive-green checkmarks plus one empty checkbox, and upper-left lighting.

Output is ONLY the crate-and-checklist symbol, centered and fully isolated on a truly transparent alpha background. Remove all title text, background, floor and ground shadow. No border, no surrounding props, no new emblems. The crate fills about 86% of the square with a clear margin on all sides, nothing cropped.

Make a deliberately simplified small-size sprite version of the reference, not a highly detailed illustration: approximately 64x64 logical pixel design enlarged with nearest-neighbor clarity. Strong crisp stair-stepped silhouette. Fewer clean pixel clusters and much less wood grain. Preserve both visible braced faces, the empty dark opening, and the slightly lighter left face. The checklist card should be large enough to identify at 64px: three neat rows of dark marks, first two with subdued olive checked boxes, last one an empty checkbox. All card marks share the face's correct perspective. Keep the color count restrained (roughly 16–20 colors), plain handcrafted Project Zomboid-style survival inventory sprite. No smoothing, blur, glossy 3D rendering, glow, dense texture, or extraneous lighting. Simple consistent geometry and readable wood plank seams.

Square icon asset with real alpha transparency, not a checkerboard illustration. This is the standalone matching icon, not a cover image or mockup.
```

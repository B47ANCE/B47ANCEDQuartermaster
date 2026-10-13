# A02 — Stable explicit item identity design (not implemented)

The current saved contract keys explicit rules by display name. A type-key change cannot be safely hidden inside a diagnostics hotfix: selection, normalization, shared-name aliases, preset coverage and counts all use those keys. No conversion occurs in dev.18.

The next bounded correctness pass should introduce independently represented exact FullType rules and legacy name aliases, with a versioned configuration/preset contract. Category IDs and taxonomy protocol 6 do not change merely because item identity changes. A future schema change requires a justified migration, peer capability change and read compatibility; it is not authorized as an unrecorded schema-2 extension.

Required semantics:

1. Preserve all historical name rules verbatim as aliases. Missing or ambiguous names remain editable/removable; never guess one FullType from a translated name.
2. New exact selections persist native FullType; localized names are labels only. Player-renamed instances retain type routing. Deliberate shared-name rules remain a separate alias operation with their documented breadth.
3. Shared-name UI selection must enumerate its actual registry members when intentionally used; never use Catalog's single representative icon FullType as the complete membership.
4. Preserve explicit precedence over categories, category normalization and additive presets. Clearing one exact type must not silently clear unrelated legacy aliases or other types sharing a label. Explain retained alias coverage.
5. Count effective distinct selectable identities according to an explicitly approved compatibility rule; do not double-count a type covered by an alias and exact rule. Keep legacy effective-name counts readable and distinguish any changed public semantics.
6. Preset copies, session working state, clipboard, Whole Container, visible/range operations, pending conflicts and old peers must share the same contract.

Offline acceptance must cover both-language registries, English saved aliases, intentional multi-type aliases, missing mods, renamed items, alias/type conflicts, full/partial normalization, stale preset generations, and unchanged open/cancel. Dedicated acceptance must include an English server and two clients with different languages plus save/restart. The original A02 audit reproduction remains applicable: current routing is still display-name dependent.

Status: **DEFERRED implementation**. P0 dedicated recovery is the handoff's first acceptance boundary. This document is a migration design constraint record, not a claim that cross-language sorting is fixed.

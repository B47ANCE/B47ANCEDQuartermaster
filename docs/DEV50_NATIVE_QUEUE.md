# Native transfer batch assembly

Project Version: 0.4.0-dev.50

Compatible PATCH correction from dev.49. Lua-only runtime; no protocol, schema,
destination, category, server-authority or sandbox-default change.

## Evidence and cause

[VERIFIED scoped runtime] User confirms the prior one-item stop fixed. The
dev.49 client console reports 140 completed transfers, zero transfer failures,
client/server dev.49 and 1,467 noMatchingRule skips. A later no-work run reports
zero transfer failures. User clarifies the current symptom: the character stays
at the container and continues transferring, rather than leaving and returning.

[VERIFIED installed source, PZ 42.21.0] ISTimedActionQueue.addToQueue begins the
first action immediately when the queue is empty. ISInventoryTransferAction.start
calls checkQueueList before submitting its first item transaction. B47 previously
added the head before adding donors, so immediate start could submit one item
before the other authorized actions existed in the queue. A regression with 20
matching light items fails on the pre-fix code: first submitted count is one.

Native checkQueueList combines up to 20 matching full-type items of weight 0.1
or less. Other types/heavier items retain separate native groups. One continuous
container queue can therefore still show individual item animations; that alone
does not indicate the queue is missing items.

## Correction and boundaries

BatchExecutor uses native ISQueueActionsAction:new and its begin/endAddingActions
path to insert the complete authorized batch before the head begins. Native
queue-list merging, timing, capacity checks and item transactions stay in place.
The gate is tagged as owned by the batch; cancellation stops it and relinquishes
outstanding grants. Its callback refuses to add work after closure. Every head
and donor retains the existing final item/state/containment checks and dev.48
stable item-ID lookup. No forced bulk mutation or shared queue/global override.

Existing server SortBatchSize remains authoritative (default 20, supported
1–100). It limits planning batches; this correction does not queue an unbounded
inventory at once. Native per-group limits remain internal engine behavior.
No meaningful new gameplay option is introduced by queue assembly.

## Validation

Exact commands from project root using configured Python:

```text
python tests/run_tests.py
python scripts/check_versions.py --root .
python scripts/check_deployment.py
python scripts/check_vanilla_membership.py --game "E:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid" --output <local-report.json> --approved-changes docs/DEV41_APPROVED_TAXONOMY_CHANGES.json
```

The pipeline fixture loads installed native ISQueueActionsAction and
ISInventoryTransferAction methods; Java action scheduling, networking and item
transactions remain simulated. It checks first-group size 20, mixed light groups,
one open per eligible single-container batch, native heavy-item behavior,
pre-transfer cancellation, favorite changes, stable-wrapper lookup, replication
gaps, late arrival, native rejection, capacity, ground source and existing routing.

[TESTED offline] Full suite PASS; version consistency and 127-file source
manifest PASS. Vanilla membership remains 5,092 items and exactly the existing
625 approved deviations. The successful native-transfer run on dev.49 remains
separate from this candidate's offline evidence.

Published dev.49 ZIP is preserved at dist/history/0.4.0-dev.49 with unchanged
SHA-256 38c657936fa1fc6f7a7cac16761bc6ff3189bbce586226295c5ef989f13d8189.
Its publication receipt and staging remain unchanged. No deletion, new package,
local deployment, Workshop upload, Steam restart or game/server launch.

[RUNTIME GATE] Test dev.50 with 20+ matching light items, mixed heavy/light items,
same destination, multiple destinations/carriers and cancellation. Verify one
continuous native queue per eligible batch, exact counts, no duplicate/lost
items and authoritative outcomes on dedicated MP. Native animation/network
acceptance is not established by offline tests. G7 NOT TESTED/BLOCKED; stable
G8 BLOCKED. Current server log copy is historical, not new dev.50 evidence.

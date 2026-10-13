## dev.24 bounded planning and native transfer queue

[VERIFIED — source] Sort plans a bounded batch rather than the complete run, then requests another batch while the current batch is being prepared/executed. Prefetch respects the existing server discovery session scope; outside that scope the character returns before requesting more work. At most two batches of outstanding operations are retained. The server sandbox SortBatchSize defaults to 20, bounded 1–100; existing saves inherit 20. The internal 100-candidate scan bound and two-batch buffer are technical scheduling limits.

Compatible transfers sharing a source, carrier and destination are queued as ordinary ISInventoryTransferAction actions and merged by the installed vanilla queue-list implementation. Vanilla grouping, weight-dependent timing and transaction handling remain in control. No accelerated transfer duration or custom item add/remove path is introduced. Cancellation invalidates owned queued donors. Shopping retains its existing executor.

The server still grants and confirms each item independently. Requests within a batch overlap; completion counts require server observation at the destination. Capacity reservations cover outstanding plans without double-counting native container contents. Native PZ retains its previously documented final item-mutation authority boundary; this does not establish a new atomic B47 authorization hook inside private Java mutations.

Movement capability is now 2. Client and server must run matching builds. Taxonomy/schema versions are unchanged. This is a compatible enhancement within the 0.4.0 development series, with a new development checkpoint rather than a public stable release.

[TESTED — offline] Production planner/authority/executor and installed vanilla queue-list/perform code are exercised with simulated engine/network leaves. Tests cover batch/quantity boundaries, native donor wiping, immediate queue starts, MP and SP branches, capacity reservations, changed eligibility/capacity, cancellation, sandbox bounds, conservation and mixed-peer rejection. Offline execution is not native multiplayer evidence.

[RUNTIME GATE] G7 NOT TESTED / BLOCKED: dedicated server and remote client must verify startup latency, overlapping batches, native bulk transfers, cancellation and rule/capacity changes. G8 BLOCKED. No package, deployment or publication was requested for this implementation.

# Inventory category capability research

Reference: Better Sorting (BetterSortCC), inventory categorization. Narrow question: can category labels and Category-column ordering share the engine category value?

Reference source NOT INSPECTED: no matching BetterSortCC mod.info found in the installed E: Workshop tree or named local mods. Public Workshop identity: 2313387159. Do not attribute a specific implementation to this mod without source evidence.

[VERIFIED native source] Installed ISInventoryPane.lua:2170 builds row.cat from item:getDisplayCategory() or item:getCategory(); :2178 sorts by itemSortFunc. Category comparators :242-253 compare row.cat, with name tie-breaking. Category text :2547-2549 translates IGUI_ItemCat_ plus the same display category/fallback. Thus native category metadata is capable of affecting both label and inventory ordering; translated visible labels and raw sorting keys are distinct.

[VERIFIED owned source] InventoryCategories.lua only substitutes drawText inside renderdetails and restores it afterward. It never changes row.cat, item definitions or Category comparators. Existing behavior intentionally leaves vanilla ordering. Missing visible replacement in the user's earlier session remains unresolved; this finding does not prove its cause.

Design consequence: independently implement consistent label and category sort-key behavior from the owned taxonomy and verified native boundaries. Decide whether to use presentation-level row keys/comparators or native display-category metadata only after auditing impact on item definitions and other systems. No implementation or deployment in this research pass.

SOURCE CODE COPIED: NO
IMPLEMENTATION DERIVED FROM REFERENCE: NO

Remaining verification: obtain actual BetterSortCC source location for a narrow capability-only inspection; independently audit native writable category APIs and lifetime, then test owned classification and inventory ordering against the actual runtime/UI chain. Current local console reports server dev.23; no dev.27 visual acceptance obtained.

## Downloaded reference follow-up

[VERIFIED file inspection] Better Sorting 2.1.5 (BetterSortCC), installed at E:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2313387159/mods/BetterSorting/42. Narrow capability inspection detects display-category setters and item parameter calls; no renderdetails or Category comparator overrides were found. No category values, algorithms, tables or implementation were imported.

[VERIFIED independent native API] Installed projectzomboid.jar exposes public InventoryItem.getDisplayCategory()Ljava/lang/String;, setDisplayCategory(Ljava/lang/String;)V; Script Item.getDisplayCategory()Ljava/lang/String; and public DoParam(Ljava/lang/String;)V / DoParam(Ljava/lang/String;Ljava/lang/String;)V. Vanilla inventory row construction and rendering independently establish the shared category mechanism above. The source presence is not native execution evidence. Instance overrides versus script-definition updates and affected systems still require an original lifecycle audit before implementation.

SOURCE CODE COPIED: NO
IMPLEMENTATION DERIVED FROM REFERENCE: NO

No inventory category implementation changed in this UI-only handoff.

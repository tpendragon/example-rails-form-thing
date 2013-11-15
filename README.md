DataStructure
====

Need to put details here - still figuring out api though.  This repo is
just a prototype anyway - the libraries will end up somewhere else.

todo
---

* Allow redeclaring attributes to add options?  Allows for splitting up attribute declarations
  into multiple classes / decorators while still keeping attribute definition central
* Consider a way to allow "plugins" to modify attribute renderer
  * Allows for simple, base renderer that just works, but allows for context-specific rendering,
    such as making a field read-only for certain roles, or invisible to guest users, or
    editable only on the "new" view, etc.
* Make attribute-only structures work (with no sections, a fieldset for "nil" still exists)

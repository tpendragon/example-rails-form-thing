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
* Allow attribute renderer's label tag to be customized (currently hard-coded to h2)
* Use simple form's wrapper rules if possible so type attribute (with subtypes) wraps the
  type/value combo as if it's a single in-line field.
  * I think this would eliminate the manual `<p>` tag.
* Figure out a way to get the form builder right at the top level of the renderer object
  * Customized `form_for` helper?  `structured_form_for(renderer)`
  * Some kind of context / binding magic to allow the Renderer instance access to the view data
    at the time rendering happens?
  * Option: make Renderer API not expose data, require use of top-level "render" call
    * Form builder is stored at top level once `render(form)` is called
    * Subclasses are not directly useable
    * All rendering logic uses view rendering so it's easier to override
    * App-wide helpers should be kept to a minimum, but should still exist as necessary to
      allow for overriding the more complex logic
    * If views and helpers are completely overrideable, many other to-dos go away
* Figure out multiple fields JS
  * Cocoon
    * PRO: It's basically all built for us, and has an active codebase
    * CON: Requires some workarounds to work with fake associations
    * CON: Requires partials to exist; can't specify proc to build HTML or raw HTML even
  * Cocoon-like implementation?
    * CON: Custom means we maintain it all
    * CON: Potentially more effort
    * PRO: The parts of cocoon we'd rewrite are very small - ~100 lines, maybe less since
      our implementation is simpler than what they offer
    * PRO: Cocoon's JS is likely useable without modification
    * ...can we use cocoon to keep the JS and just override the helpers we need to customize?
  * Hack together quick and dirty solution
    * Something like this: http://www.9lessons.info/2010/04/jquery-duplicate-field-form-submit-with.html
      * JQuery plugin: http://www.andresvidal.com/labs/relcopy.html
    * PRO: Should be very simple UI-only code
    * CON: Not as well-maintained as Cocoon
    * PRO: Doesn't require any "template" html - just clones a DOM element and clears out its data
    * CON: Requires each form field (`titles`, `creators`, etc.; not one for each subtype) to exist in
      the DOM at least in an empty state
* Figure out a way to better support "traditional" ORM
  * Arrays don't auto-serialize in ActiveRecord - have different options for :multiple key?
    * `multiple: true` means allow multiples as we do now
    * `multiple: :serialize` means allow multiples but serialize and deserialize the array

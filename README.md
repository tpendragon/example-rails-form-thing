DataStructure
====

Allows a class, generally an ORM class of some sort, to define various "magic" attributes at a
low level.  These attribute definitions are, at their core, meant to allow for an easier time
dealing with complex metadata for digital assets.  The idea is to allow for a web form to be
built dynamically, arrays of data to be delegated to a "field" on the ORM that can serialize or
re-delegate the data elsewhere, and for complex metadata to be able to be represented in a simpler
way without requiring an app to build confusing back-end translation logic.

Certain assumptions are made for this system, which almost certainly won't fit all use cases, but
hopefully can be adjusted for others who need such a system:

* Your ORM class will have attributes / methods which can handle all DataStructure-defined
  attributes - if an attribute accepts multiple values (list of subjects, for instance), your
  class needs to be able to handle an array of data
  * Specifically, ActiveRecord column-based methods will not take arrays
* All data can be defined as being one of the following:
  * Simple string field ("asset type", for instance)
  * String list field (list of subjects or keywords)
  * "Grouped" string list field (list of titles with types: "main title", "alternate", etc)
    * In this case, each type of title must map to its own field: `main_title`, `alt_title`, etc
    * Each field needs to be able to take an array, at least for now, and translate that as
      necessary if the underlying ORM doesn't want arrays

Usage
---

For decoration, create a subclass of the container decorator.  For an example, see the source
for the [GenericAssetStructure](app/decorators/generic_asset_structure.rb).  To see how that example
works nicely with ActiveRecord, check out [GenericAsset](app/models/generic_asset.rb).

**Note**: *Mixing [DataStructure::Container](lib/data_structure/container.rb) into your ORM class should work, but has not yet been tested directly.*

In your decorated class, you define your attributes and their options.  Note that if a field is
not defined, it is assumed that the attribute's name will match an accessor directly.

Long-term goals include:

* Adding controlled vocabularies to make certain string fields show an autocomplete and restrict
  responses to the values defined.
* Adding contextual information to attributes defining when they're shown (new/edit/index/...),
  but allowing this to be specified externally (allowing values of some attribute to influence
  this, for instance)
* Adding user-based contextual requirements, such that specific roles may have access to certain
  fields others can't see and/or edit, etc.
* Creating a template system to store pre-filled forms
* Create two or more gems to encompass specific bits of functionality, with a base "structure" gem
  which would be the foundation for others:
  * Core structure (depends on draper and activemodel most likely)
    * View-rendering and form-builder (engine)
      * Views based on context
    * Controlled vocabulary

todo
---

Stuff I need to track that belongs in issues maybe, but meh

* Allow redeclaring attributes to add options?  Allows for splitting up attribute declarations
  into multiple classes / decorators while still keeping attribute definition central
* Consider a way to allow "plugins" to modify attribute renderer
  * Allows for simple, base renderer that just works, but allows for context-specific rendering,
    such as making a field read-only for certain roles, or invisible to guest users, or
    editable only on the "new" view, etc.
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
* Extract structure into a gem, renderer into a separate gem which depends on structure
  * Structure can apply to any project even without a web front-end
  * Renderer is very specific to a Rails project using simpleform right now
  * Renderer probably needs to be a Rails engine to make it really powerful with overrideable views,
    appwide helpers, etc.  Structure definitely doesn't need all that.

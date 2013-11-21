require "#{Rails.root}/lib/data_structure/container_decorator"

# API (WIP) for a generic form "structure decorator" which would allow one to
# declare form groupings and how to delegate to the model method(s).  Assumes
# simple_form for now, as its labeling, hint, and placeholder systems are
# already well-defined and offer a lot of flexibility.
class GenericAssetStructure < DataStructure::ContainerDecorator
  decorates GenericAsset

  # Maybe something like this so that attribute declarations can be validated
  # as belonging to a legitimate section?  I'm not sure I like this vs.
  # wrapping in a `section` block, but wrapping attributes in a block might not
  # make sense going the virtus route.
  #
  # Sections are sort of UI-only elements, too, so maybe they don't make sense
  # being declared here.  Each section is a fieldset which wraps all items in
  # the block, but there's no meaning to the individual attributes -- this is a
  # grouping thing to keep related fields together.  We could have an I18n
  # lookup for the fieldset's "legend" element, and optionally allow a label
  # here.
  has_sections :asset_metadata, :extra_data

  # Titles "attribute" - many can be chosen, but they must come in with a
  # "type" for each value.  At least one must be specified, but it doesn't
  # matter which. This validation has to be part of the structure since the ORM
  # would have a lot more work to validate that any one of the title attributes
  # are filled out.
  #
  # In code, specifying titles data might look like this:
  #
  #     # Object is not valid - "One or more titles must be present" or something.
  #     object.titles = []
  #
  #     object.titles = [{type: :main, value: "Thing"}, {type: :series, value: "A trilogy of things"}]
  #
  # Once set, each title is individually delegated, so the effect above would
  # be the same as this:
  #     object.main_title = ["Thing"]
  #     object.series_name = ["A trilogy of things"]
  #
  # Maybe have more settings to determine if the delegated attribute is an
  # array or a single value.  Some sub-types might not make sense with multiple
  # values even though the "attribute" itself does, and other sub-types could.
  # (for instance, main title might only happen once, but there could be
  # multiple alternate titles)
  attribute :titles, multiple: true, required: true, section: :asset_metadata do |title|
    # Main title delegates to the ORM model's main_title attribute - this may
    # be something we want to add a magic extension for in the case of
    # OregonDigital - we might actually want this to have another option where
    # we can specify our specific RDF predicate mapping, and have some
    # behind-the-scenes magic which turns that into a dynamic attribute on the
    # model *and* the datastream.  That's pretty OD-specific, though, so I
    # need to think it through some.
    title.subtype :main, field: :main_titles

    title.subtype :alternate, field: :alt_titles
    title.subtype :parallel, field: :parallel_titles

    # If field isn't specified, it defaults to attribute name - for subtypes,
    # this can be a bit confusing, because :series might mean something
    # different in another attribute block, but both would use :series and
    # :series= if field isn't specified.
    title.subtype :series
  end

  # Not required, but otherwise similar to titles
  attribute :creators, multiple: true, section: :asset_metadata do |creator|
    creator.subtype :creator, field: :creator_array
    creator.subtype :photographer, field: :photographers
    creator.subtype :author, field: :authors
  end

  # Simple field for allowing multiple subjects to be entered, requiring at
  # least one.  The lack of subtypes means we have to specify the field
  # directly at the top level.
  attribute :subjects, multiple: true, required: true, section: :asset_metadata, field: :subject_array

  # `Type` field has no subtypes and doesn't allow multiple values, so it's
  # just a standard text field with a label.
  attribute :type, required: true, section: :asset_metadata

  # Administrative data goes in its own section - this would probably be read-only for most roles,
  # but for OD I think that would just be part of a more view-oriented decorator or something
  attribute :administrative, multiple: true, section: :extra_data do |admin_field|
    admin_field.subtype :replaces, field: :admin_replaces_array
    admin_field.subtype :full, field: :original_full_asset_path_array
    admin_field.subtype :conversion_specifications, field: :admin_conversion_spec_array
  end

  # TODO: Is this useful or necessary?  Right now subtypes don't really work
  # without the `multiple` field set to true.  More specifically, when
  # foo_attributes= is called with data for subtype :x, the data for subtype :y
  # is left in place, which is very confusing.  Need to either force multiple
  # to be true for subtype data or else implement something that can do what's
  # described below.
  #
  # This is a very contrived case, but this would allow a mutually exclusive
  # field that still does delegation to subtypes.  Since multiple is not true,
  # even though there are three separate fields, one has to be chosen, and that
  # choice will force the other values to be cleared.  In other words, THERE
  # CAN BE ONLY ONE.
  #
  #     attribute :favorite_pet_name, section: :extra_data do |f|
  #       f.subtype :cat
  #       f.subtype :dog
  #       f.subtype :pig
  #     end
end

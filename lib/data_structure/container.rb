require 'active_support'
require 'ostruct'

# Minimal code to make the prototype work.  This code will ABSOLUTELY SUCK.
# It's not meant for long-term use!
#
# TODO: Figure out the right way to make mass assignment work - specialized
# includes for specific ORMs?  Or just create a basic set_attributes method
# that doesn't use ORM stuff and has to be used directly from controllers?  Not
# sure here.
#
# Okay, for starters, set_attributes should be done in any case, and if
# ORM-specific stuff is needed, at least the basic setter can just be called
# instead of reimplemented.
module DataStructure
  module Container
    extend ActiveSupport::Concern

    included do
      attr_reader :object, :attributes

      @attributes = []
      @attribute_names = {}
    end

    # TODO: This part only works if defining a decorator, but will break if
    # used directly on an ORM model.  Need to make this work in both cases by
    # splitting up decorator behaviors from core data structure stuff.
    def initialize(object)
      @object = object
    end

    # TODO: Same note as above - this is only necessary for decorators
    def method_missing(method, *args, &block)
      return super unless delegatable?(method)
      object.send(method, *args, &block)
    end

    # TODO: Same note as above - this is only necessary for decorators
    def respond_to_missing?(method, include_private = false)
      return super || delegatable?(method)
    end

    # TODO: Same note as above - this is only necessary for decorators
    def delegatable?(method)
      return object.respond_to?(method)
    end

    module ClassMethods
      def sections(*section_list)
        raise RuntimeError.new("Cannot reassign sections") if @valid_sections
        @valid_sections = section_list
      end

      # Defines an attribute on the model
      def attribute(name, options = {}, &block)
        raise RuntimeError.new("Attribute #{name.inspect} may not be specified twice") if @attribute_names[name]

        attr = AttributeDefinition.new(name, options, &block)
        attr.validate_section!(@valid_sections)

        add_translation_methods(attr) if attr.needs_translation?

        @attributes << attr
        @attribute_names[name] = attr
      end

      def add_translation_methods(attribute)
        name = attribute.name
        reader = name
        writer = "#{name}="

        if respond_to?(reader) || respond_to?(writer)
          raise RuntimeError.new("Cannot define an attribute which overrides existing methods (#{name.inspect})")
        end

        define_method(:prepare_attribute) do |name|
          @attributes ||= {}
          @attributes[name] ||= AttributeTranslator.new(self, attribute)
        end

        define_method(reader) do
          prepare_attribute(name)
          return @attributes[name].get
        end

        define_method(writer) do |val|
          prepare_attribute(name)
          @attributes[name].set(val)
        end

        if attribute.needs_attributes_writer?
          attribute_writer = "#{name}_attributes="
          define_method(attribute_writer) do |val|
            prepare_attribute(name)
            @attributes[name].attributes = val
          end
        end
      end
    end
  end
end

class AttributeDefinition
  attr_accessor :name, :subtypes, :section, :field, :required, :multiple, :subtype_lookup

  def initialize(name, opts = {}, &block)
    @name = name
    @subtypes = []
    @section = opts[:section]
    @field = opts.fetch(:field, @name)
    @multiple = opts.fetch(:multiple, false)
    @required = opts.fetch(:required, false)
    @subtype_lookup = {}

    block.call(self) if block
  end

  def validate_section!(valid_sections)
    if !valid_sections
      return if !section
      raise RuntimeError.new("Class must define valid sections before attributes may use sections")
    end

    raise RuntimeError.new("Class requires a :section option") unless section
    raise RuntimeError.new("Invalid section #{section.inspect}") unless valid_sections.include?(section)
  end

  def subtype(name, opts = {})
    # Subtypes can only have a name and a field delegation for now
    attr = OpenStruct.new(name: name, field: opts[:field] || name)
    subtypes << attr
    subtype_lookup[name] = attr
  end

  # Is translation necessary?  i.e., will the base class need a reader/writer
  # method to get and set the data?
  #
  # When is translation necessary?
  # - Subtypes - the top-level attribute is *always* a translation layer because it will receive
  #   a hash of complex data which need to be translated into the various attributes
  # - "Forwarded" fields - the attribute methods need to call the real method
  def needs_translation?
    return @field != @name || @subtypes.any?
  end

  def needs_attributes_writer?
    return @subtypes.any?
  end
end

class AttributeTranslator
  def initialize(context_model, attr)
    @context_model = context_model
    @attribute_definition = attr

    setup_translators
  end

  def translation_type
    return :subtype_array if @attribute_definition.subtypes.any?
    return :field_forward if @attribute_definition.field != @attribute_definition.name

    raise "Cannot determine translation type!"
  end

  def setup_translators
    case translation_type
      when :subtype_array
        @reader = method(:get_subtype_data)
        @writer = method(:set_subtype_data)

      when :field_forward
        # TODO: allow for more complex forwarding to allow for just sending straight
        # through the model and into its datastream?
        reader = @attribute_definition.field
        writer = "#{reader}="
        @reader = @context_model.method(reader)
        @writer = @context_model.method(writer)
    end
  end

  # Converts each value for each subtype into a hash of type and value
  def get_subtype_data
    data = []
    for attr in @attribute_definition.subtypes
      value = @context_model.method(attr.field).call
      next if value.nil?
      value = [value] unless value.is_a?(Array)
      value.each {|val| data.push(type: attr.name, value: val)}
    end

    return data
  end

  def get
    return @reader.call
  end

  # Converts all hashes into subtype values, not affecting subtype data which
  # isn't explicitly set in the array of values
  def attributes=(values)
    data = Hash.new

    # First aggregate the values so we have a type-to-value map, and we ensure
    # that all values are getting array-ified
    for hash in values
      type = hash[:type]
      data[type] ||= []
      data[type].push(hash[:value])
    end

    # Now do the assignments
    for subtype_name, values in data
      subtype = @attribute_definition.subtype_lookup[subtype_name]
      @context_model.method(subtype.field.to_s + "=").call(values)
    end
  end

  # Converts all hashes into subtype values, clearing any subtypes that don't
  # have an item in the values array
  def set_subtype_data(values)
    for attr in @attribute_definition.subtypes
      @context_model.method(attr.field.to_s + "=").call(nil)
    end

    self.attributes = values
  end

  def set(val)
    return @writer.call(val)
  end
end

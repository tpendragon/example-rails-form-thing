require 'active_support'

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

    def respond_to_missing?(method, include_private = false)
      return super || delegatable?(method)
    end

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

        # TODO: Make this read the source data!
        define_method(reader) do
          @attributes ||= {}
          @attributes[name] ||= AttributeInstance.new(attribute)
          return @attributes[name]._get
        end

        # TODO: Make this write to the source data!
        define_method(writer) do |val|
          @attributes ||= {}
          @attributes[name] ||= AttributeInstance.new(attribute)
          @attributes[name]._set(val)
        end
      end
    end
  end
end

class AttributeDefinition
  attr_accessor :name, :subtypes, :section, :field, :required, :multiple

  def initialize(name, opts = {}, &block)
    @name = name
    @subtypes = []
    @section = opts[:section]
    @field = opts.fetch(:field, @name)
    @multiple = opts.fetch(:multiple, false)
    @required = opts.fetch(:required, false)

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
    subtypes << AttributeDefinition.new(name, opts)
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
end

class AttributeInstance
  def initialize(attr)
    @attribute_definition = attr
  end

  # TODO: Access model and use options to figure out how to retrieve this value
  def _get
    return @value
  end

  # TODO: Access model and use options to figure out how to set this value
  def _set(val)
    @value = val
  end
end

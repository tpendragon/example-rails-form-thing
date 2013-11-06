require 'active_support'

# Minimal code to make the prototype work.  This code will ABSOLUTELY SUCK.
# It's not meant for long-term use!
module DataStructure
  module Container
    extend ActiveSupport::Concern

    included do
      attr_reader :object, :attributes

      @attributes = []
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
        section = options[:section]
        if @valid_sections
          raise RuntimeError.new("Must specify :section option") unless section
          raise RuntimeError.new("Invalid section #{section.inspect}") unless @valid_sections.include?(section)
        else
          raise RuntimeError.new("May not specify :section option without first defining sections") if section
        end

        attr = AttributeDefinition.new(name, options)
        block.call(attr) if block

        reader = name
        writer = "#{name}="

        if respond_to?(reader) || respond_to?(writer)
          raise RuntimeError.new("Cannot define an attribute which overrides existing methods (#{name.inspect})")
        end

        @attributes << attr

        # Define reader
        define_method(reader) do
          @attributes ||= {}
          return @attributes[name]
        end

        # Define writer
        define_method(writer) do |val|
          @attributes ||= {}
          @attributes[name] = val
        end
      end
    end
  end
end

class AttributeDefinition
  attr_accessor :name, :subtypes, :opts

  def initialize(name, opts = {})
    @name = name
    @opts = opts
    @subtypes = []
  end

  def subtype(name, opts = {})
    subtypes << AttributeDefinition.new(name, opts)
  end
end

class AttributeInstance
  # TODO: Access model and use options to figure out how to retrieve this value
  def _get
    return @value
  end

  # TODO: Access model and use options to figure out how to set this value
  def _set(val)
    @value = val
  end
end

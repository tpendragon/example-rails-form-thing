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
      return super unless object.respond_to?(method)
      object.send(method, *args, &block)
    end

    module ClassMethods
      def sections(*section_list)
        @valid_sections = section_list
      end

      # Defines an attribute on the model
      def attribute(name, options = {}, &block)
        attr = AttributeDefinition.new(name, options)
        if block
          block.call(attr)
        end

        @attributes << attr

        # Define reader TODO: unless it already exists
        define_method(name) do
          @attributes ||= {}
          return @attributes[name]
        end

        # Define writer TODO: unless it already exists
        define_method(name.to_s + "=") do |val|
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

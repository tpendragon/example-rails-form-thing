require_relative "label_translator"

module DataStructure
  class Renderer
    attr_reader :section_renderers, :model

    def initialize(model)
      @model = model
      @class = model.class
      setup_section_renderers
    end

    def setup_section_renderers
      @section_renderers = {}
      if @class.sections.nil? || @class.sections.empty?
        @section_renderers[nil] = SectionRenderer.new(nil, @model)
        return
      end

      for section in @class.sections
        @section_renderers[section] = SectionRenderer.new(section, @model)
      end
    end
  end

  class SectionRenderer
    attr_reader :name, :model, :attribute_renderers

    def initialize(name, model)
      @name = name
      @model = model
      @class = model.class
      setup_attribute_renderers
    end

    def label
      LabelTranslator.new(model, name).translate
    end

    def setup_attribute_renderers
      @attribute_renderers = {}
      for attribute in @class.attributes
        next if attribute.section && attribute.section != @name
        @attribute_renderers[attribute.name] = AttributeRenderer.new(attribute, @model)
      end
    end
  end

  class AttributeRenderer
    def initialize(attr_definition, model)
      @attr_definition = attr_definition
      @model = model
    end

    # I don't like this - probably should build a simpleform extension or a renderable view
    # template or something
    def field(form_builder)
      if @attr_definition.subtypes.empty?
        return form_builder.input @attr_definition.name, as: :string
      end

      typename = @attr_definition.name
      LabelTranslator.new(@model, typename).translate
      label = form_builder.label @attr_definition.name
      inputs = form_builder.fields_for(@attr_definition.name) do |f|
        type_field = f.input_field :type, :collection => subtype_options
        value_field = f.input_field :value, as: :string

        type_field << value_field
      end

      return label << inputs
    end

    def subtype_options
      return @attr_definition.subtypes.collect do |subtype|
        [LabelTranslator.new(@model, subtype.name).translate, subtype.name]
      end
    end
  end
end

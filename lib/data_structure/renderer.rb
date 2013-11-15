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

    def render_inputs(form_builder)
      output = "".html_safe
      for section_renderer in section_renderers.values
        output << section_renderer.render(form_builder)
      end

      return output
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

    def render(builder)
      template = builder.template
      controls = "".html_safe
      for attribute_renderer in attribute_renderers.values
        controls << attribute_renderer.field(builder)
      end

      if name
        old_controls = controls
        controls = template.content_tag(:fieldset) do
          template.content_tag(:legend, label) << old_controls
        end
      end

      return controls
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

    def field(form_builder)
      opts = {class: "attribute-field #{@attr_definition.name}"}
      return form_builder.template.content_tag :div, field_html(form_builder), opts
    end

    def field_html(form_builder)
      attrname = @attr_definition.name
      template = form_builder.template
      required = @attr_definition.required

      if @attr_definition.subtypes.empty?
        return form_builder.input attrname, as: :string, required: required
      end

      label_opts = {}
      label_text = LabelTranslator.new(@model, attrname).translate

      if required
        label_opts[:required] = true
        required_text = SimpleForm::Inputs::Base.translate_required_html
        label_text = required_text.html_safe + label_text
      end

      label = template.content_tag :h2, label_text, label_opts

      inputs = form_builder.fields_for(attrname) do |f|
        type_field = f.input_field :type, :collection => subtype_options
        value_field = f.input_field :value, as: :string

        type_field << value_field << template.content_tag(:p)
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

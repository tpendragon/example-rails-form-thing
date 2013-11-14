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
    attr_reader :name, :model

    def initialize(name, model)
      @name = name
      @model = model
    end

    def label
      LabelTranslator.new(model, name).translate
    end
  end

  class AttributeRenderer
  end
end

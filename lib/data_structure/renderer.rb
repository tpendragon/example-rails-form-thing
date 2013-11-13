module DataStructure
  class Renderer
    attr_reader :sections, :model

    def initialize(model)
      @model = model
      @class = model.class
      setup_sections
    end

    def setup_sections
      @sections = {}
      if @class.sections.nil? || @class.sections.empty?
        @sections[nil] = SectionRenderer.new(nil, @model)
        return
      end

      for section in @class.sections
        @sections[section] = SectionRenderer.new(section, @model)
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
      LabelTranslator.new(model).translate(name)
    end
  end

  class AttributeRenderer
  end
end

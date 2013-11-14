require "active_support/core_ext"

module DataStructure
  # Acts as a bridge between a DataStructure object and the form builder to get labels since labels
  # need to be used for subtypes as more of an option / dropdown choice rather than field label.
  class LabelTranslator
    def initialize(model, attribute_name)
      @model = model
      @attribute_name = attribute_name
    end

    def model_name
      if @model.class.respond_to?(:model_name)
        return @model.class.model_name.to_s.underscore
      end

      return @model.class.to_s.underscore
    end

    def translated_label
      lookups = [:"#{model_name}.#{@attribute_name}", :"defaults.#{@attribute_name}", ""]

      return I18n.t(lookups.shift, scope: :"simple_form.labels", default: lookups).presence
    end

    def humanized_attribute_name
      if @model.class.respond_to?(:human_attribute_name)
        return @model.class.human_attribute_name(@attribute_name.to_s)
      end

      return @attribute_name.to_s.humanize
    end

    # Returns the text describing the given attribute for the model
    #
    # TODO: Make this use a form builder directly somehow (Rails and SimpleForm both seem to keep
    # their label logic heavily buried - i.e., no way to just say "give me the label for foo.bar")
    def translate
      return translated_label || humanized_attribute_name
    end
  end
end

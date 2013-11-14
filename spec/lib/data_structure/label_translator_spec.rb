# Isolated testing for speed
require_relative "../../../lib/data_structure/label_translator"

describe DataStructure::LabelTranslator do
  let(:model) { double("model") }
  subject { DataStructure::LabelTranslator.new(model, :some_attr_symbol) }

  describe "#translate" do
    it "should use translated_label" do
      subject.stub(:translated_label => "translated")
      expect(subject.translate).to eq("translated")
    end

    it "should fall back on humanized_attribute_name if translated_label is nil" do
      subject.stub(:translated_label => nil)
      subject.stub(:humanized_attribute_name => "humanized")
      expect(subject.translate).to eq("humanized")
    end
  end

  describe "#humanized_attribute_name" do
    it "should call human_attribute_name if available" do
      model.class.stub(:human_attribute_name => "humanized internally")
      expect(subject.humanized_attribute_name).to eq("humanized internally")
    end

    it "should manually humanize the class if human_attribute_name doesn't exist" do
      expect(subject.humanized_attribute_name).to eq("Some attr symbol")
    end
  end

  # This is a very simple test to avoid too much testing on exact I18n rules as I'm still not
  # sure what will really make sense for externalizing strings here
  describe "#translated_label" do
    it "should use I18n rules" do
      model.class.stub(:model_name).and_return("ModelName")
      expect(I18n).to receive(:t).
                      with(:"model_name.some_attr_symbol", hash_including(scope: :"simple_form.labels")).
                      and_return("Translated")
      expect(subject.translated_label).to eq("Translated")
    end
  end
end

# Isolated testing for speed
require_relative "../../../lib/data_structure/renderer"

describe DataStructure::Renderer do
  let(:renderee) { double("model") }
  let(:renderer) { DataStructure::Renderer.new(renderee) }

  before(:each) do
    # Make renderee act as if it has sections and such so all the internal API bits work
    renderee.class.stub(:sections => [:foo, :bar])
  end

  describe ".new" do
    it "should create a new DataStructure::Renderer wrapping the given object" do
      expect(renderer.model).to eq(renderee)
    end

    it "should create sections" do
      expect(renderer.sections.length).to eq(2)
      expect(renderer.sections[:foo]).to be_kind_of(DataStructure::SectionRenderer)
      expect(renderer.sections[:bar]).to be_kind_of(DataStructure::SectionRenderer)
    end
  end
end

describe DataStructure::SectionRenderer do
  let(:model) { double("model") }
  subject { DataStructure::SectionRenderer.new(:name, model) }

  describe "#label" do
    it "should use LabelTranslator" do
      LabelTranslator = double("label translator class")
      lt = double("label translator instance")

      LabelTranslator.stub(:new).with(model).and_return(lt)
      lt.stub(:translate => "translated")

      expect(subject.label).to eq("translated")
    end
  end
end

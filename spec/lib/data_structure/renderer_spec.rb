# Isolated testing for speed
require_relative "../../../lib/data_structure/renderer"
require_relative "../../../lib/data_structure/label_translator"

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

    it "should create section renderers" do
      expect(renderer.section_renderers.length).to eq(2)
      expect(renderer.section_renderers[:foo]).to be_kind_of(DataStructure::SectionRenderer)
      expect(renderer.section_renderers[:bar]).to be_kind_of(DataStructure::SectionRenderer)
    end
  end
end

describe DataStructure::SectionRenderer do
  let(:model) { double("model") }
  subject { DataStructure::SectionRenderer.new(:name, model) }

  describe "#label" do
    it "should use LabelTranslator" do
      lt = double("label translator instance")
      DataStructure::LabelTranslator.should_receive(:new).with(model, :name).and_return(lt)
      lt.stub(:translate => "translated")

      expect(subject.label).to eq("translated")
    end
  end
end

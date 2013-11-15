# Isolated testing for speed
require_relative "../../../lib/data_structure/renderer"
require_relative "../../../lib/data_structure/label_translator"

describe "Renderers" do
  let(:model) { double("model") }
  before(:each) do
    # Make model act as if it has sections and such so all the internal API bits work
    model.class.stub(:sections => [:foo, :bar])
    model.class.stub(:attributes => [])
  end


  describe DataStructure::Renderer do
    let(:renderer) { DataStructure::Renderer.new(model) }

    describe ".new" do
      it "should create a new DataStructure::Renderer wrapping the given object" do
        expect(renderer.model).to eq(model)
      end

      it "should create section renderers" do
        expect(renderer.section_renderers.length).to eq(2)
        expect(renderer.section_renderers[:foo]).to be_kind_of(DataStructure::SectionRenderer)
        expect(renderer.section_renderers[:bar]).to be_kind_of(DataStructure::SectionRenderer)
      end
    end
  end

  describe DataStructure::SectionRenderer do
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
end

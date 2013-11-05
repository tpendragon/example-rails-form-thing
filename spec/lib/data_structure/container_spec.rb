# NOTE: Tests are going to be as bad as the prototype code itself until things are more finalized

# Isolated testing for speed
require_relative "../../../lib/data_structure/container"

describe DataStructure::Container do
  let(:decoratee) { TestDelegatee.new }
  subject { TestDecorator.new(decoratee) }

  # This is VERY BAD.  Just need to make this work properly for prototyping,
  # then I swear I'll fix it!
  before(:each) do
    class TestDelegatee
      def delegation
        return 1
      end

      def to_s
        return "This is TestDelegatee's to_s method"
      end
    end

    class TestDecorator
      include DataStructure::Container

      sections :asset_metadata, :other_data

      # Simplest case - attribute with no real rules
      attribute :thing, section: :other_data

      # Simple case - required attribute with no other rules
      attribute :identifier, required: true, section: :other_data

      # Semi-simple case - attribute with multiples allowed
      attribute :subjects, required: true, section: :other_data, multiple: true

      # Complex case - attribute with sub-types but no multiple values
      attribute :option, required: true, section: :asset_metadata do |option|
        option.subtype :first, delegation: :option_1
        option.subtype :alternate, delegation: :option_2
      end

      # Complex case - attribute with sub-types and allowance for multiple values
      attribute :titles, multiple: true, required: true, section: :asset_metadata do |title|
        title.subtype :main, delegation: :main_title
        title.subtype :alternate, delegation: :alt_title
        title.subtype :parallel, delegation: :parallel_title
        title.subtype :series, delegation: :series_name
      end

      # Local function operating on local data
      def modify
        @something ||= 0
        @something += 1
      end

      # Another local function wheee
      def get
        return @something
      end
    end
  end

  after(:each) do
    Object.send(:remove_const, :TestDecorator) if Object.const_defined?(:TestDecorator)
    Object.send(:remove_const, :TestDelegatee) if Object.const_defined?(:TestDelegatee)
  end

  context "decoration magic" do
    it "should create a new decorated object" do
      expect(subject).to be_kind_of(TestDecorator)
      expect(subject.object).to eql(decoratee)
    end

    it "should delegate to the decorated object" do
      expect(subject.delegation).to eq(subject.object.delegation)
    end

    it "should still respond to local methods" do
      subject.modify
      expect(subject.get).to eq(1)
    end

    it "should override decorated object methods" do
      expect(subject.to_s).not_to eq(subject.object.to_s)
    end
  end

  describe ".sections" do
    it "should create valid section data" do
      expect(subject.class.instance_variable_get("@valid_sections")).to eq([:asset_metadata, :other_data])
    end

    it "shouldn't allow assigning sections twice" do
      expect { TestDecorator.sections :foo, :bar }.to raise_error(RuntimeError, /cannot reassign/i)
    end
  end

  describe ".attribute" do
    it "should create a getter on the decorated class" do
      expect { subject.foo }.to raise_error(NameError)
      TestDecorator.attribute :foo, section: :other_data
      expect { subject.foo }.not_to raise_error
    end

    it "should create a setter on the decorated class" do
      expect { subject.foo = 1 }.to raise_error(NameError)
      TestDecorator.attribute :foo, section: :other_data
      expect { subject.foo = 1 }.not_to raise_error
    end
  end
end

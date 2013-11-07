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
    end

    class TestDecorator
      include DataStructure::Container

      sections :asset_metadata, :other_data

      def get
        return 1
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

  # Some of this belongs on the attribute classes, but as those are even less
  # certain than the container class, testing will go here for now
  describe ".attribute" do
    context "(when sections are specified)" do
      it "should work if a valid section is given" do
        expect { TestDecorator.attribute :foo, section: :other_data }.not_to raise_error
      end

      it "should raise an error if section is omitted" do
        expect { TestDecorator.attribute :foo }.to raise_error(RuntimeError, /section/)
      end

      it "should raise an error if an invalid section is given" do
        expect { TestDecorator.attribute :foo, section: :invalid }.to raise_error(RuntimeError, /section/)
      end
    end

    context "(when no sections are specified)" do
      before(:each) do
        TestDecorator.send(:remove_instance_variable, "@valid_sections")
      end

      it "should work if no section is given" do
        expect { TestDecorator.attribute :foo }.not_to raise_error
      end

      it "should raise an error if a section is given" do
        expect { TestDecorator.attribute :foo, section: :other_data }.to raise_error(RuntimeError, /section/)
      end
    end

    context "(when translation is necessary)" do
      before(:each) do
        AttributeDefinition.any_instance.stub(:needs_translation? => true)
      end

      it "should create a getter on the decorated class" do
        expect { subject.foo }.to raise_error(NameError)
        subject.class.send(:attr_accessor, :bar)
        TestDecorator.attribute :foo, section: :other_data, field: :bar
        expect { subject.foo }.not_to raise_error
      end

      it "should create a setter on the decorated class" do
        expect { subject.foo = 1 }.to raise_error(NameError)
        subject.class.send(:attr_accessor, :bar)
        TestDecorator.attribute :foo, section: :other_data, field: :bar
        expect { subject.foo = 1 }.not_to raise_error
      end

      context "(when an attribute by the same name is already defined)" do
        it "should raise an exception" do
          TestDecorator.attribute :foo, section: :other_data
          error_match = /:foo may not be specified twice/i
          expect { TestDecorator.attribute :foo, section: :other_data }.to raise_error(RuntimeError, error_match)
        end
      end

      context "(when the getter or setter override existing methods)" do
        it "should raise an exception" do
          expect { TestDecorator.attribute :to_s, section: :other_data }.to raise_error(RuntimeError, /override/)
        end

        it "should not modify the class" do
          stringified = subject.to_s

          # Ignore the error without testing for error specifics
          expect { TestDecorator.attribute :to_s, section: :other_data }.to raise_error

          expect(subject.to_s).to eq(stringified)
        end
      end
    end

    context "(when translation isn't necessary)" do
      before(:each) do
        AttributeDefinition.any_instance.stub(:needs_translation? => false)
      end

      it "should create a getter on the decorated class" do
        expect { subject.foo }.to raise_error(NameError)
        TestDecorator.attribute :foo, section: :other_data
        expect { subject.foo }.to raise_error(NameError)
      end

      it "should create a setter on the decorated class" do
        expect { subject.foo = 1 }.to raise_error(NameError)
        TestDecorator.attribute :foo, section: :other_data
        expect { subject.foo = 1 }.to raise_error(NameError)
      end
    end
  end

  context "(data translation)" do
    context "(when data is simply forwarded)" do
      before(:each) do
        subject.stub(:bar)
        subject.stub(:bar=)
        TestDecorator.attribute :foo, section: :other_data, field: :bar
      end

      it "should retrieve data from the defined field" do
        expect(subject).to receive(:bar).once.and_return("test")
        expect(subject.foo).to eq("test")
      end

      it "should send data to the defined field" do
        expect(subject).to receive(:bar=).once
        subject.foo = 1
      end
    end

    context "(when data is translated to subtypes)" do
      before(:each) do
        TestDecorator.attribute :foo, section: :other_data do |foo|
          foo.subtype :bar
          foo.subtype :baz, field: :qux
        end
      end

      it "should retrieve what was set" do
        val = [{type: :bar, value: "this is bar"}, {type: :baz, value: "this is baz, but its field is qux"}]
        subject.foo = val
        expect(subject.foo).to eq(val)
      end
    end
  end
end

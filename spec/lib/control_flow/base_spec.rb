require 'spec_helper'

describe ControlFlow::Base do

  let(:klass) do
    Class.new(ControlFlow::Base) do

      define_flow :free do
        add_step :one
      end
      
      define_step :one do

      end

    end
  end

  let(:object) do
    klass.new(context)
  end

  let(:context_klass) do
    Class.new do

      attr_reader :called

      def initialize
        @called = []
      end

      def amazing_method
        true
      end

      def return_name
        'zomg'
      end

    end
  end

  let(:context) do
    context_klass.new
  end

  describe "#self.inherited" do

    context "when inheriting from base" do

      specify { ControlFlow::Base.steps.object_id.should_not == klass.steps.object_id }
      specify { ControlFlow::Base.flows.object_id.should_not == klass.flows.object_id }

    end

  end

  describe "#self.define_flow" do

    before do
      klass.define_flow :paid do
        add_step(:one)
      end
    end

    it "should have created new flow class stored in flows[:paid]" do
      inherited_from = (ControlFlow::Flow > klass.flows[:paid])
      inherited_from.should === true
    end

    it "should have executed block in class creation context" do
      klass.flows[:paid].step_list.should == [:one]
    end

  end

  describe "#self.define_step" do

    before do
      klass.define_step :login do
        value(:one)
      end
    end

    it "should have created new step class stored in flows[:paid]" do
      inherited_from = (ControlFlow::Step > klass.steps[:login])
      inherited_from.should === true
    end

    it "should have executed block in class creation context" do
      klass.steps[:login]._value.should == :one
    end

  end

  context "#initialize" do

    it "should have setup context in object" do
      object.context.should == context
    end

  end

  context "#enter_flow" do

    context "when flow is valid" do
      before do
        klass.define_step :one do

        end
        object.enter_flow(:free)
      end

      specify { klass.steps[:one].should_not be_nil }

      it "should have initialized flow as current_flow" do
        object.current_flow.should be_an(ControlFlow::Flow)
        object.current_flow.context.should == context
      end

      it "should have set current steps in flow" do
        object.current_flow.steps.keys.should == object.steps.keys
      end

    end

    context "when flow is invalid" do
      before do
        klass.define_step :one do

        end
      end

      it "should raise invalid flow exception" do
        lambda { object.enter_flow(:fake) }.should raise_exception(
          ControlFlow::Base::InvalidFlow,
          "invalid flow given use: #{object.flows.keys.join(', ')}"
        )
      end

    end

  end

  context "#enter_step" do

    context "when flow is set" do

      before do
        object.enter_flow(:free)
        object.enter_step(:one)
      end

      it "should have entered state :one in free flow" do
        expected = object.current_flow.steps[:one]
        object.current_flow.current_step.should == expected
      end

    end

    context "when no flow is given" do

      it "should raise exception" do
        lambda { object.enter_step(:one) }.should raise_exception(
          ControlFlow::Base::InvalidStatus,
          'must enter a state before setting step'
        )
      end

    end

  end

  describe "#respond_to?" do

    before do
      object.enter_flow(:free)
      object.enter_step(:one)

      # flexmock(object.current_flow).should_receive(:valid?).once
    end

    it "should return true when given valid?" do
      object.should respond_to(:valid?)
    end

    it "should return false when given invalid method" do
      object.should_not respond_to(:wowzomg)
    end

  end
  
  describe "#method_missing" do

    before do
      object.enter_flow(:free)
      object.enter_step(:one)
    end

    it "should call valid? on flow when called on base" do
      object.should be_valid
    end

  end

end

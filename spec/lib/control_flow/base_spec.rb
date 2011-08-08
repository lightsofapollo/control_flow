require 'spec_helper'

describe ControlFlow::Base do

  let(:klass) do
    create_base do
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

      specify { ControlFlow::Base.defined_steps.object_id.should_not == klass.defined_steps.object_id }
      specify { ControlFlow::Base.defined_flows.object_id.should_not == klass.defined_flows.object_id }

    end

  end

  describe "#self.define_flow" do

    before do
      klass.define_flow :paid do
        add_step(:one)
      end

      klass.define_flow :free do
        add_step(:two)
      end
    end

    it "should have created new flow class stored in.defined_flows[:paid]" do
      inherited_from = (ControlFlow::Flow > klass.defined_flows[:paid])
      inherited_from.should === true
    end

    it "should have executed block in class creation context" do
      klass.defined_flows[:paid].step_list.should == [:one]
    end

    it "should have setup second flow" do
      klass.defined_flows[:free].step_list.should == [:two]
    end

  end

  describe "#self.define_step" do

    before do
      klass.define_step :login do
        value(:one)
      end
    end

    it "should have created new step class stored in.defined_flows[:paid]" do
      inherited_from = (ControlFlow::Step > klass.defined_steps[:login])
      inherited_from.should === true
    end

    it "should have executed block in class creation context" do
      klass.defined_steps[:login]._value.should == :one
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
        klass.define_step :two do

        end

        klass.define_step :three do

        end

        klass.define_flow :paid do
          add_step(:three, :two)
        end

        object.enter_flow(:free)
      end

      specify { klass.defined_steps[:one].should_not be_nil }

      it "should have initialized flow as current_flow" do
        object.current_flow.should be_an(ControlFlow::Flow)
        object.current_flow.context.should == context
      end

      it "should have set current steps in flow" do
        object.enter_flow(:free)
        object.steps.keys.should == [:one]
      end

      context "when switching flows" do

        before do
          object.enter_flow(:free)
        end

        it "should not contaminate new flow after switching" do
          object.enter_flow(:paid)
          object.steps.keys.should == [:three, :two]
        end

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
          "invalid flow given use: #{object.defined_flows.keys.join(', ')}"
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

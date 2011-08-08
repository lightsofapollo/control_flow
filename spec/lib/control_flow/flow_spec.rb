require 'spec_helper'

describe ControlFlow::Flow do

  def self.create_complicated_steps

    class_eval do

      let(:steps) do
        {
          :login => create_step,
          :profile => create_step,
          :checkout => create_step,
          :complete => create_step
        }
      end

      let(:object) do
        klass.add_step(steps.keys)
        klass.new(context, steps)
      end

      before do
        steps[:login].is_complete do
          called << :complete_login
          amazing_method # Returns true
        end

        steps[:profile].depends_on(:login).is_complete do
          called << :complete_profile
          amazing_method
        end

        steps[:checkout].depends_on(:profile).is_complete do
          called << :complete_checkout
          amazing_method
        end

        steps[:complete].depends_on(:checkout, :login).is_complete do
          called << :complete_complete
          amazing_method
        end.validates do
          called << :validates_complete
          amazing_method
        end
      end
    end
  end


  let(:klass) do
    @klass
  end

  before do
    @klass = Class.new(ControlFlow::Flow)
  end

  let(:object) do
    klass.add_step(steps.keys)

    klass.new(context, steps)
  end

  let(:steps) do
    {:one => create_step, :two => create_step, :three => create_step}
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

  describe "#self.add_step" do

    before do
      klass.add_step(:one)
      klass.add_step(:two, :three)
      klass.add_step([:four])
    end


    it "should add steps to step_list in order" do
      klass.step_list.should == [:one, :two, :three, :four]
    end

  end

  describe "#inherited" do

    let(:flow1) do
      Class.new(klass) do
        add_step(:one, :two)
      end
    end

    let(:flow2) do
      Class.new(klass) do
        add_step(:three, :four)
      end
    end

    it "should not share steps" do
      flow2.step_list.should_not == flow1.step_list
    end
    
    specify { flow1.step_list.should == [:one, :two] }
    specify { flow2.step_list.should == [:three, :four] }

  end

  describe "#initialize" do

    context "when successful but add step order is reverse of step defintion order" do

      before do
        # This reversal is intentional!
        klass.add_step(:two, :one)
      end
      
      let(:steps) do
        {:one => create_step, :two => create_step, :five => create_step}
      end
      
      let(:expected_steps) do
        allowed = steps.clone
        allowed.delete(:five)
        allowed
      end

      let(:object) do
        klass.new(context, steps)
      end

      it "should have assigned steps to steps" do
        object.steps.keys.map(&:to_s).sort.should == expected_steps.keys.map(&:to_s).sort
      end

      it "should assign context" do
        object.context.should == context
      end

      it "should initialize steps" do
        expected_steps.each do |key, value|
          object.steps[key].should be_an(value)
          object.steps[key].context.should == context
        end
      end

    end

    context "when missing steps" do

      before do
        klass.add_step(:two, :three, :one)
      end

      let(:steps) do
        {
          :one => create_step, 
          :sevenity_x => create_step, 
          :four => create_step,
          :three => create_step
        }
      end

      let(:object) do
        klass.new(context, steps)
      end

      it "should raise exception" do
        lambda { object }.should raise_exception(RuntimeError, "Missing step: two")
      end

    end

  end

  describe "#enter_step" do

    context "when successful" do

      before do
        object.enter_step(:one)
      end

      it "should set current_step to one" do
        object.current_step.should == object.steps[:one]
      end

      it "should have set correct state" do
        object.current_step.name.should == :one
      end

    end

    context "when given a step instance" do

      before do
        object.enter_step(object.steps[:two])
      end

      it "should have set current step to the second step (:two)" do
        object.current_step.should == object.steps[:two]
      end

    end

    context "when invalid step is given" do

      it "should raise an exception when given an invalid type" do
        lambda { object.enter_step(:invalid) }.should raise_exception(
          klass::InvalidStep, 
          "invalid step given use: #{object.step_list.join(', ')}"
        )
      end

    end

  end


  describe "#reference_step_position" do

    before do
      object.enter_step(:two)
    end

    it "should return :one when using -1" do
      object.reference_step_position(-1).should == object.steps[:one]
    end

    it "should return :two when using -1 with given step" do
      step = object.reference_step_position(-1, object.steps[:three])
      step.should == object.steps[:two]
    end

    it "should return :two when using -1 with given step as symbol" do
      step = object.reference_step_position(-1, :three)
      step.should == object.steps[:two]
    end

    it "should return :three when using 1" do
      step = object.reference_step_position(1)
      step.should == object.steps[:three]
    end

    it "should return false when using -1 on the :one step" do
      step = object.reference_step_position(-1, :one)
      step.should === false
    end

    it "should return false when using 1 on :three step" do
      step = object.reference_step_position(1, object.steps[:three])
      step.should === false
    end


  end

  describe "#next_step" do

    context "when at the first step" do

      before do
        object.enter_step(:one)
      end

      it "should return an instance of the next step" do
        object.next_step.should == object.steps[:two]
      end

    end

    context "when at the middle step" do

      before do
        object.enter_step(:two)
      end

      it "should return an instance of the next step" do
        object.next_step.should == object.steps[:three]
      end

      

    end

    context "when at the last step" do

      before do
        object.enter_step(:three)
      end

      it "should return false" do
        object.next_step.should === false
      end
      

    end


  end

  describe "#previous_step" do

    context "when at the first step" do

      before do
        object.enter_step(:one)
      end

      it "should return false" do
        object.previous_step.should === false
      end

    end

    context "when at the last step" do

      before do
        object.enter_step(:three)
      end

      it "should return an instance of the next step" do
        object.previous_step.should == object.steps[:two]
      end

    end

  end


  describe "#valid?" do
    create_complicated_steps

    let(:expected_called) do
      [
        :complete_login,
        :complete_profile,
        :complete_checkout,
        :validates_complete
      ]
    end

    all_called = proc do
      context.called.should == expected_called
    end

    context "when valid" do
      before do
        object.enter_step(:complete)
        @result = object.valid?
      end

      it "should return true" do
        @result.should == true
      end

      specify(&all_called)
    end

    context "when invalid" do
      before do
        steps[:complete].validates do
          called << :validates_complete
          false
        end

        object.enter_step(:complete)
        @result = object.valid?
      end

      it "should return false" do
        @result.should == false
      end

      it "should set last_valid_step to previous_step" do
        object.last_valid_step.should == object.previous_step
      end

      specify(&all_called)
    end

    context "when step deps are not met" do

      before do
        steps[:checkout].is_complete do
          called << :complete_checkout
          false
        end

        object.enter_step(:complete)
        @result = object.valid?
      end
  
      it "should return false" do
        @result.should == false
      end
      it "should have set last_valid_step to :profile" do
        object.last_valid_step.should == object.steps[:checkout]
      end
    end
  end


  describe "#step_dependencies_met?" do
    create_complicated_steps
    
    let(:expected_called) do
      [
        :complete_login,
        :complete_profile,
        :complete_checkout
      ]
    end

    def self.calculate_result
      class_eval do
        before do
          object.enter_step(:complete)
          @result = object.send(:step_dependencies_met?)
        end

        it "should have checked deps in correct order" do
          context.called.should == expected_called
        end

      end
    end

    context "when all deps are met" do
      calculate_result

      it "should return true" do
        @result.should === true
      end

    end

    context "when step dep is not met and last step is valid" do

      before do
        steps[:checkout].is_complete do
          called << :complete_checkout
          false
        end
      end

      calculate_result

      it "should return false" do
        @result.should === false
      end

      it "should set last_valid_step to :profile" do
        object.last_valid_step.should == object.steps[:checkout]
      end

    end

    context "when step dep is not met and last step is invalid" do
      before do

        steps[:checkout].is_complete do
          called << :complete_checkout
          false
        end.validates do
          called << :validates_complete
          false
        end

        expected_called << :validates_complete
      end

      calculate_result

      it "should return false" do
        @result.should === false
      end

      it "should set last_valid_step to :profile" do
        object.last_valid_step.should == object.steps[:profile]
      end

    end


  end

  describe "#calculate_step_dependencies" do
    create_complicated_steps

    before do
      object.enter_step(:complete)
    end

    let(:list) do
      object.send(:calculate_step_dependencies)
    end

    it "should return a list of all depedencies in order of steps" do
      list.should == [:login, :profile, :checkout]
    end

  end

  describe "#step_value" do

    before do
      steps[:one].value do
        return_name
      end

      object.enter_step(:one)
    end

    it "should return the value of current state" do
      object.step_value.should == 'zomg'
    end

  end


end

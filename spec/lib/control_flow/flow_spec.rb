require 'spec_helper'

describe ControlFlow::Flow do

  def create_step
    Class.new(ControlFlow::Step)
  end

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
          amazing_method # Returns true
        end

        steps[:profile].depends_on(:login)
        steps[:checkout].depends_on(:profile)
        steps[:complete].depends_on(:checkout, :login)
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

  describe "#initialize" do

    context "when successful" do

      before do
        klass.add_step(:one, :two)
      end
      
      let(:steps) do
        {:one => create_step, :two => create_step}
      end

      let(:object) do
        klass.new(context, steps)
      end

      it "should have assigned steps to steps" do
        object.steps.keys.should == steps.keys
      end

      it "should assign context" do
        object.context.should == context
      end

      it "should initialize steps" do
        steps.each do |key, value|
          object.steps[key].should be_an(value)
          object.steps[key].context.should == context
        end
      end

    end

    context "when missing steps" do

      before do
        klass.add_step(:one, :two)
      end

      let(:steps) do
        {:one => create_step}
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


  describe "#step_dependancies_met?" do


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
      list.should == [:checkout, :profile, :login]
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

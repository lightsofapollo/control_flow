require 'spec_helper'

describe ControlFlow::Step do

  let(:klass) do
    Class.new(ControlFlow::Step) do
    end
  end

  let(:context_klass) do
    Class.new do

      def was_true
        true
      end

      def test_url
        'test/url'
      end

    end
  end

  let(:context) do
    context_klass.new
  end

  let(:object) do
    klass.new(context)
  end

  let(:block) do
    proc { true }
  end

  describe "#self.value" do

    before do
      klass.value('zomg')
    end

    it "should set self._value to given" do
      klass._value.should == 'zomg'
    end

  end

  describe "#self.depends_on" do

    context "when given value" do

      before do
        klass.depends_on(:one, :two)
      end

      it "should set self._dependants to [:one, two]" do
        klass._dependents.should == [:one, :two]
      end

    end

    context "when given block" do

      let(:block) do
        proc { [:one, :two] }
      end

      before do
        klass.depends_on(&block)
      end

      it "should set self._dependants to [:one, :two]" do
        klass._dependents.should === block
      end

    end

  end

  describe "#self.validates" do

    before do
      klass.validates(&block)
    end

    it "should set _validates to block" do
      klass._validates.object_id.should == block.object_id
    end

  end

  describe "#self.is_complete" do

    before do
      klass.is_complete(&block)
    end

    it "should set _is_complete to block" do
      klass._is_complete.object_id.should == block.object_id
    end

  end

  describe "#new" do
    
    it "should set object.context" do
      object.context.should == context
    end

  end

  describe "#dependencies" do

    context "when given static values" do

      before do
        klass.depends_on(:one, :two)
      end
    
      it "should return depends_on set" do
        object.dependencies.should == [:one, :two]
      end

    end

    context "when given block" do

    end

  end

  describe "#value" do

    before do
      klass.value('zomg')
    end

    it "should return class attribute of _value" do
      object.value.should == 'zomg'
    end

  end

  [:complete?, :valid?].each do |block_method|

    set_method = {:complete? => :is_complete, :valid? => :validates}[block_method]

    describe "##{block_method}" do

      def was_called=(val)
        @was_called = val
      end

      def was_called
        @was_called
      end

      after do
        @was_called = false
      end

      context "when is false" do

        before do
          copy = self
          klass.send(set_method) do
            copy.was_called = true
            was_true === false
          end

          @result = object.send(block_method)
        end

        it "should be false when is complete returns false" do
          @result.should === false
        end

        specify { was_called.should === true }

      end


      context "when is true" do

        before do
          copy = self
          klass.send(set_method) do
            copy.was_called = true
            was_true === true
          end

          @result = object.send(block_method)
        end

        it "should be false when is complete returns false" do
          @result.should === true
        end

        specify { was_called.should === true }

      end

    end
    

  end

end

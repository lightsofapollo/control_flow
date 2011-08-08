module ControlFlow
  class Base

    class InvalidStatus < Exception
    end

    class InvalidFlow < Exception
    end

    class_attribute :defined_steps
    class_attribute :defined_flows

    attr_reader :current_flow, :context

    def self.inherited(klass)
      if(self == ControlFlow::Base)
        klass.defined_steps = {}
        klass.defined_flows = {}
      else
        klass.defined_steps = self.defined_steps.clone
        klass.defined_flows = self.defined_flows.clone
      end
      super
    end

    class << self

      # Defines a new flow class for this base
      #
      # @param [Symbol] name for the flow
      # @param [Block] class defintion for flow
      def define_flow(name, &block)
        # This is intentional because inherited is called after Class.new
        klass = self.defined_flows[name] = Class.new(Flow)
        klass.class_eval(&block)
        klass
      end

      # Defines a new step for this base
      #
      # @param [Symbol] name for the step
      # @param [Block] class defintion for step
      def define_step(name, &block)
        # This is intentional because inherited is called after Class.new
        step = self.defined_steps[name] = Class.new(Step)
        step.class_eval(&block)
        step
      end

    end

    # Initializes control flow with given context
    # blocks in steps are evaluated in this context.
    #
    # @param [Object] context in which blocks are evaluated
    def initialize(context)
      @context = context
    end

    # Enters a flow (by name)
    #
    # @param [Symbol] name of flow
    def enter_flow(flow)
      if(defined_flows.has_key?(flow))
        send_steps = {}
        
        defined_flows[flow].step_list.each do |step|
          send_steps[step] = defined_steps[step] if defined_steps.has_key?(step)
        end

        @current_flow = defined_flows[flow].new(context, send_steps)
      else
        raise(InvalidFlow, "invalid flow given use: #{defined_flows.keys.join(', ')}")
      end
    end

    # Enters state the flow must be entered 
    # before the state can be activated
    def enter_step(state)
      if(current_flow)
        current_flow.enter_step(state)
      else
        raise(InvalidStatus, 'must enter a state before setting step')
      end
    end

    # Returns true when flow or self has method
    def respond_to?(method, *args)
      current_flow.respond_to?(method) || super
    end

    # Calls method on flow if available
    def method_missing(method, *args)
      if(current_flow.respond_to?(method))
        current_flow.send(method, *args)
      else
        super
      end
    end

  end
end

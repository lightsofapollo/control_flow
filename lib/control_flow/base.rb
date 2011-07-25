module ControlFlow
  class Base

    class InvalidStatus < Exception
    end

    class InvalidFlow < Exception
    end

    class_attribute :steps
    class_attribute :flows

    self.flows = {}
    self.steps = {}

    attr_reader :current_flow, :context

    def self.inherited(klass)
      if(self == ControlFlow::Base)
        klass.steps = self.steps.clone
        klass.flows = self.flows.clone
      end
    end

    class << self

      # Defines a new flow class for this base
      #
      # @param [Symbol] name for the flow
      # @param [Block] class defintion for flow
      def define_flow(name, &block)
        self.flows[name] = Class.new(Flow, &block)
      end

      # Defines a new step for this base
      #
      # @param [Symbol] name for the step
      # @param [Block] class defintion for step
      def define_step(name, &block)
        self.steps[name] = Class.new(Step, &block)
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
      if(flows.has_key?(flow))
        @current_flow = flows[flow].new(context, steps)
      else
        raise(InvalidFlow, "invalid flow given use: #{flows.keys.join(', ')}")
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

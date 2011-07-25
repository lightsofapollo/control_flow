module ControlFlow
  class Base

    class_attribute :steps
    class_attribute :flows

    attr_reader :current_flow

    class << self

      def define_flow(&block)

      end

      def define_step(&block)

      end

    end

    # Initializes control flow with given context
    # blocks in steps are evaluated in this context.
    #
    # @param [Object] context in which blocks are evaluated
    def initialize(context)

    end

    # Enters a flow (by name)
    #
    # @param [Symbol] name of flow
    def enter_flow(flow)

    end

    # Enters state the flow must be entered 
    # before the state can be activated
    def enter_state

    end


  end
end

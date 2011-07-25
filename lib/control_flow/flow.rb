module ControlFlow
  class Flow

    class InvalidStep < Exception
    end

    class_attribute :step_list

    self.step_list = []

    # When control flow is inherited clone step list so
    # the steps are not shared between classes
    def self.inherited(klass)
      klass.step_list = self.step_list.clone
    end

    class << self

      # Add step to control flow
      #
      # @param [Symbol] list of symbols
      def add_step(*steps)
        step_list.push(steps).flatten!
      end

    end

    attr_reader :steps, :context, :current_step

    # Initializes control flow
    #
    # @param [Object] context in which steps are executed
    # @param [Hash] list of steps
    def initialize(context, steps)
      @current_step = nil
      @steps = {}
      @steps.merge!(steps)
      @context = context

      if(@steps.keys != self.step_list)
        raise("Missing step: #{(step_list - @steps.keys).join(', ')}")
      end

      @steps.each do |name, klass|
        @steps[name] = klass.new(name, @context)
      end
    end


    # Enters the current step
    #
    # @param [Symbol, ControlFlow::Step] name or instance of the step
    def enter_step(step)
      if(step.is_a?(Step))
        step = step.name
      end

      if(steps.has_key?(step))
        @current_step = steps[step]
      else
        raise(InvalidStep, "invalid step given use: #{step_list.join(', ')}")
      end
    end

    def valid?

    end

    # Returns and instance of the next step
    #
    # @returns [ControllFlow::Step] instance of the next step
    def next_step
      index = step_list.index(current_step.name)
      if(index && (step_list.length > index + 1))
        steps[step_list[index + 1]]
      else
        false
      end
    end

    # Returns and instance of the previous step
    #
    # @returns [ControllFlow::Step] instance of the previous step
    def previous_step
      index = step_list.index(current_step.name)

      if(index && (index - 1 >= 0))
        steps[step_list[index - 1]]
      else
        false
      end

    end

    # Returns the value of the current step
    #
    # @returns [Object]
    def step_value
      current_step.value
    end


  end
end

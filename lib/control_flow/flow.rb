module ControlFlow
  class Flow

    class InvalidStep < Exception
    end

    class_attribute :step_list, :test

    # When control flow is inherited clone step list so
    # the steps are not shared between classes
    def self.inherited(klass)
      self.test ||= []
      self.test << "Called inherited"
      if(self == ControlFlow::Flow)
        klass.step_list = []
      else
        klass.step_list = self.step_list.clone
      end
      super
    end

    class << self

      # Add step to control flow
      #
      # @param [Symbol] list of symbols
      def add_step(*steps)
        if(!step_list)
          raise([self, step_list, self.test].inspect)
        end
        step_list.push(steps).flatten!
      end

    end

    attr_reader :steps, :context, :current_step, :last_valid_step

    # Initializes control flow
    #
    # @param [Object] context in which steps are executed
    # @param [Hash] list of steps
    def initialize(context, add_steps)
      @last_valid_step = nil
      @current_step = nil
      @steps = {}

      @context = context
      missing = []

      step_list.each do |step|
        unless(add_steps.has_key?(step))
          missing << step
          next
        end

        klass = add_steps[step]
        @steps[step] = klass.new(step, @context)
      end

      unless(missing.empty?)
        raise("Missing step: #{missing.join(', ')}")
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
      if(step_dependencies_met?)
        if(current_step.valid?)
          return true
        else
          @last_valid_step = previous_step
        end
      end
      false
    end

    def step_dependencies_met?
      valid = true
      deps = calculate_step_dependencies
      deps.each do |step_name|
        step = steps[step_name]

        # Check if state is complete
        if(!step.complete?)
          # If its not complete mark invalid
          valid = false
          # If step is incomplete but valid? we can enter that step
          # Thus is it the last *valid* step
          if(step.valid?)
            @last_valid_step = step
            break
          else
            # If it was not valid the last step is our best guess
            @last_valid_step = reference_step_position(-1, step)
            break
          end
        end
      end

      valid
    end

    # Calculates all depedencies to check 
    # returns them in order of step definition.
    #
    # So if step three depends on step two and two depends
    # on one the order returned would be: two, :one if we are
    # on step three and :one if we are on step two
    def calculate_step_dependencies(step = nil, current_list = nil)
      current_list ||= []

      unless(step)
        step = current_step
      end

      all_deps = []
      step_deps = step.dependencies


      unless(step_deps.blank?)
        step_deps.each do |dep|
          next if(all_deps.include?(dep))
          dep_step = steps[dep]

          all_deps << dep
          all_deps += calculate_step_dependencies(steps[dep], all_deps)
          all_deps.uniq!
        end
      end

      step_list.inject([]) do |map, value|
        map << value if all_deps.include?(value)
        map
      end
    end

    protected :step_dependencies_met?, :calculate_step_dependencies


    # Finds step by referencing given step and a position state
    #
    #     #steps = [:one, :two, :three]
    #     #current step is :two
    #
    #     object.reference_step_position(-1) # => :one
    #     object.reference_step_position(1) # => :three
    #
    # @param [Integer] position to move by can be positive or negative
    # @param [ControlFlow::Step] step to reference defaults to current step
    def reference_step_position(position, step = nil)
      step ||= current_step
      unless(step.is_a?(Symbol))
        step = step.name
      end

      index = step_list.index(step)


      total_steps = step_list.length
      new_index = (index + position)

      return false unless total_steps > 1

      if(total_steps > new_index && new_index > -1)
        steps[step_list[new_index]]
      else
        false
      end
    end

    # Returns and instance of the next step
    # 
    # @returns [ControllFlow::Step] instance of the next step
    def next_step
      reference_step_position(1)
    end

    # Returns and instance of the previous step
    #
    # @returns [ControlFlow::Step] instance of the previous step
    def previous_step
      reference_step_position(-1)
    end

    # Returns the value of the current step
    #
    # @returns [Object]
    def step_value
      current_step.value
    end


  end
end

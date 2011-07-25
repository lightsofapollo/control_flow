module ControlFlow
  class Step

    class_attribute :_dependents, :_validates, :_is_complete, :_value

    attr_reader :context, :name

    self._validates = Proc.new { true }
    self._is_complete = Proc.new { true }

    class << self
      
      # Sets the value of step designed with use with urls
      #
      # @param [Mixed] value
      def value(value = nil, &block)
        if(block_given?)
          self._value = block
        else
          self._value = value
        end

        self
      end

      # Sets the steps this step is dependant on
      #
      # @param [Symbols] list of symbols this step is dependant on
      def depends_on(*args, &block)
        if(block_given?)
          self._dependents = block
        else
          self._dependents = args.flatten
        end
        
        self
      end

      # Sets validation this step uses
      #
      # @param [Proc] logic for block
      def validates(&block)
        self._validates = block

        self
      end

      # Sets validation this step uses to verify
      # that this step is completed
      #
      # @param [Proc] logic for block
      def is_complete(&block)
        self._is_complete = block

        self
      end

    end


    # Initializes step with context
    def initialize(name, context)
      @name = name
      @context = context
    end

    def context
      @context
    end

    # Returns list of dependencies for step
    #
    # @returns [Array] list of symbols
    def dependencies
      if(self._dependents.respond_to?(:call))
        context.instance_eval(&self._dependents)
      else
        self._dependents
      end
    end

    # Returns boolean value based on logic of is_complete
    # block executed within context of the object given in
    # the initializer
    #
    # @returns [Boolean]
    def complete?
      context.instance_eval(&self._is_complete)
    end

    # Returns boolean value based on logic of is_complete
    # block executed within context of the object given in
    # the initializer
    #
    # @returns [Boolean]
    def valid?
      context.instance_eval(&self._validates)
    end

    # Returns the value set in the definition
    def value
      if(self._value.respond_to?(:call))
        context.instance_eval(&self._value)
      else
        self._value
      end
    end

  end


end

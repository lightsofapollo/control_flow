support = Module.new do  
  def create_base(&block)
    klass = Class.new(ControlFlow::Base)
    klass.class_eval(&block)
    klass
  end
end

RSpec.configure do |config|
  config.include support
end



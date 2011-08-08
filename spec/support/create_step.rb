support = Module.new do  
  def create_step
    Class.new(ControlFlow::Step)
  end
end

RSpec.configure do |config|
  config.include support
end


module ControlFlow
  require 'rubygems'
  require 'active_support/core_ext/class/attribute'
  require 'active_support/core_ext/object/blank'
  

  autoload :Base, 'control_flow/base'
  autoload :Step, 'control_flow/step'
  autoload :Flow, 'control_flow/flow'

end

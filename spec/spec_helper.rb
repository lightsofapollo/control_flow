$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
SimpleCov.start

require 'control_flow'
require 'rspec'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

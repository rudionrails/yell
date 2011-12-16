require 'time'

module Yell

  autoload :Formatter,  File.dirname(__FILE__) + '/yell/formatter'
  autoload :Logger,     File.dirname(__FILE__) + '/yell/logger'
  autoload :Adapters,   File.dirname(__FILE__) + '/yell/adapters'

  class NoSuchAdapter < StandardError; end


  def self.new( *args, &block )
    Yell::Logger.new( *args, &block )
  end

  # The environment
  def self.env
    ENV['YELL_ENV'] || ENV['RACK_ENV'] || 'development'
  end

end

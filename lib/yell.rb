module Yell

  autoload :Config,     File.dirname(__FILE__) + '/yell/config'
  autoload :Formatter,  File.dirname(__FILE__) + '/yell/formatter'
  autoload :Logger,     File.dirname(__FILE__) + '/yell/logger'
  autoload :Adapters,   File.dirname(__FILE__) + '/yell/adapters'

  # custom errors
  class NoAdaptersDefined < StandardError; end
  class NoSuchAdapter < StandardError; end


  def self.new( *args, &block )
    Yell::Logger.new( *args, &block )
  end
  
  def self.config
    @@config ||= Yell::Config.new
  end

end

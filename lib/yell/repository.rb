# encoding: utf-8

require 'monitor'
require "singleton"

module Yell #:nodoc:

  class LoggerNotFound < StandardError
    def message; "Could not find a Yell::Logger instance with the name '#{super}'"; end
  end

  class Repository
    extend MonitorMixin
    include Singleton

    attr_accessor :loggers

    def initialize
      @loggers = {}
    end

    class << self
      # Set loggers in the repository
      #
      # @example Set a logger
      #   Yell::Repository[ 'development' ] = Yell::Logger.new :stdout
      #
      # @return [Yell::Logger] The logger instance
      def []=( name, logger )
        synchronize { instance.loggers[name] = logger }
      end

      # Get loggers from the repository
      #
      # @example Get the logger
      #   Yell::Repository[ 'development' ]
      #
      # @raise [Yell::LoggerNotFound] Raised when repository does not have that key
      # @return [Yell::Logger] The logger instance
      def []( name )
        synchronize { instance.fetch(name) or raise Yell::LoggerNotFound.new(name) }
      end

      # Get the list of all loggers in the repository
      #
      # @return [Hash] The map of loggers
      def loggers
        synchronize { instance.loggers }
      end
    end


    # Fetch the logger by the given name.
    #
    # If the logger could not be found and has a superclass, it 
    # will attempt to look there. This is important for the 
    # Yell::Loggable module.
    def fetch( name )
      logger = loggers[name] || loggers[name.to_s]

      if logger.nil? && name.respond_to?(:superclass)
        return fetch( name.superclass )
      end

      logger
    end

  end
end


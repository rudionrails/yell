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

    # Set loggers in the repository
    #
    # @example Set a logger
    #   Yell::Repository[ 'development' ] = Yell::Logger.new :stdout
    #
    # @return [Yell::Logger] The logger instance
    def self.[]=( name, logger )
      synchronize { instance.loggers[name] = logger }
    end

    # Get loggers from the repository
    #
    # @example Get the logger
    #   Yell::Repository[ 'development' ]
    #
    # @raise [Yell::LoggerNotFound] Raised when repository does not have that key
    # @return [Yell::Logger] The logger instance
    def self.[]( name )
      synchronize do
        logger = instance.loggers[name] || instance.loggers[name.to_s]

        if logger.nil? && name.respond_to?(:superclass)
          return Yell::Repository[ name.superclass ]
        end

        logger or raise Yell::LoggerNotFound.new(name)
      end
    end

    # Get the list of all loggers in the repository
    #
    # @return [Hash] The map of loggers
    def self.loggers
      synchronize { instance.loggers }
    end

  end
end


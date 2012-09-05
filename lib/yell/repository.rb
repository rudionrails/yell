# encoding: utf-8

require 'monitor'
require "singleton"

module Yell #:nodoc:
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
    # @return [Yell::Logger] The logger instance
    def self.[]( name )
      synchronize { instance.loggers[name] }
    end

    # Get the list of all loggers in the repository
    #
    # @return [Hash] The map of loggers
    def self.loggers
      synchronize { instance.loggers }
    end

    # Clears all logger instances (handy for testing)
    def self.clear
      synchronize { instance.loggers.clear }
    end

  end
end


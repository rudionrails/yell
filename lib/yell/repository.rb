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

  end
end


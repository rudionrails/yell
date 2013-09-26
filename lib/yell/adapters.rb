# encoding: utf-8
module Yell #:nodoc:

  # AdapterNotFound is raised whenever you want to instantiate an 
  # adapter that does not exist.
  class AdapterNotFound < StandardError; end

  # This module provides the interface to attaching adapters to
  # the logger. You should not have to call the corresponding classes
  # directly.
  module Adapters

    # holds the list of known adapters
    @adapters = {}

    # Register your own adapter here
    #
    # @example
    #   Yell::Adapters.register( :myadapter, MyAdapter )
    def self.register( name, klass )
      @adapters[name] = klass
    end

    # Returns an instance of the given processor type.
    #
    # @example A simple file adapter
    #   Yell::Adapters.new( :file )
    def self.new( name, options = {}, &block )
      return name if name.is_a?(Yell::Adapters::Base)

      adapter = case name
      when STDOUT then @adapters[:stdout]
      when STDERR then @adapters[:stderr]
      else @adapters[name]
      end

      raise AdapterNotFound.new(name) if adapter.nil?

      adapter.new(options, &block)
    end

    # Thanks, railties :-)
    def self.broadcast( adapter )
      Module.new do
        define_method(:write) do |event|
          adapter.write(event)
          super(event)
        end

        define_method(:close) do
          adapter.close
          super()
        end
      end
    end

  end
end

# Base for all adapters
require File.dirname(__FILE__) + '/adapters/base'

# IO based adapters
require File.dirname(__FILE__) + '/adapters/io'
require File.dirname(__FILE__) + '/adapters/streams'
require File.dirname(__FILE__) + '/adapters/file'
require File.dirname(__FILE__) + '/adapters/datefile'


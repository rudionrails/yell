# encoding: utf-8

module Yell #:nodoc:

  # NoSuchAdapter is raised whenever you want to instantiate an 
  # adapter that does not exist.
  class NoSuchAdapter < StandardError; end

  # This module provides the interface to attaching adapters to
  # the logger. You should not have to call the corresponding classes
  # directly.
  module Adapters
    @@adapters = {}

    class << self

      # Register your own adapter here
      #
      # @example
      #   Yell::Adapters.register( :myadapter, MyAdapter )
      def register( name, klass )
        @@adapters[name] = klass
      end

      # Returns an instance of the given processor type.
      #
      # @example A simple file adapter
      #   Yell::Adapters.new( :file )
      def new( name, options = {}, &block )
        return name if name.is_a?( Yell::Adapters::Base )

        adapter = case name
          when STDOUT then @@adapters[:stdout]
          when STDERR then @@adapters[:stderr]
          else @@adapters[name]
        end

        raise NoSuchAdapter.new( name ) unless adapter

        adapter.new( options, &block )
      end

    end

  end
end

require 'yell/adapters/base'

# IO based adapters
require 'yell/adapters/io'
require 'yell/adapters/streams'
require 'yell/adapters/file'
require 'yell/adapters/datefile'


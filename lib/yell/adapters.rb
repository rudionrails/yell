# encoding: utf-8

require 'yell/adapters/base'
require 'yell/adapters/io'
require 'yell/adapters/file'
require 'yell/adapters/datefile'

module Yell #:nodoc:

  # NoSuchAdapter is raised whenever you want to instantiate an 
  # adapter that does not exist.
  class NoSuchAdapter < StandardError; end

  # This module provides the interface to attaching adapters to
  # the logger. You should not have to call the corresponding classes
  # directly.
  module Adapters

    class << self
      # Returns an instance of the given processor type.
      #
      # @example A simple file adapter
      #   Yell::Adapters[ :file ]
      def new( type, options = {}, &block )
        # return type if type.instance_of?(Yell::Adapters::)

        if type.instance_of?( ::IO )
          # should apply to STDOUT, STDERR, File, etc
          Yell::Adapters::Io.new( type, options, &block )
        else
          # any other type
          adapter = case type
            when String, Symbol then self.const_get( camelize(type.to_s) )
            else type
          end

          adapter.new( options, &block )
        end
      end


      private

      # Simple camelcase converter.
      #
      # @example
      #   camelize("file")
      #   #=> "File"
      #
      #   camelize("date_file")
      #   #=> "DateFile"
      def camelize( str )
        str.capitalize.gsub( /(_\w)/ ) { |match| match.reverse.chop.upcase }
      end
    end

  end
end

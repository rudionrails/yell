# encoding: utf-8

require 'yell/adapters/base'
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
    extend self

    # Returns an instance of the given processor type.
    #
    # @example A simple file adapter
    #   Yell::Adapters.new :file
    def new( type, options = {}, &block )
      klass = case type
        when String, Symbol then self.const_get( camelize(type.to_s) )
        else type
      end

      klass.new( options, &block )
    rescue NameError => e
      raise Yell::NoSuchAdapter, "no such adapter #{type.inspect}"
    end


    private

    # Simple camelcase converter
    #
    # @example
    #   "file "#=> "File"
    #   "date_file" #=> "DateFile"
    def camelize( str )
      str.capitalize.gsub( /(_\w)/ ) { |match| match.reverse.chop.upcase }
    end

  end
end

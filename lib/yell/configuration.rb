# encoding: utf-8

require 'yaml'

module Yell #:nodoc:

  # The Configuration can be used to setup Yell before
  # initializing an instance.
  class Configuration

    def self.load!( file )
      YAML.load( ::File.read(file) )
    end

  end
end


# encoding: utf-8

require 'erb'
require 'yaml'

module Yell #:nodoc:

  # The Configuration can be used to setup Yell before
  # initializing an instance.
  class Configuration

    def self.load!( file )
      yaml = YAML.load( ERB.new(File.read(file)).result )

      # in case we have ActiveSupport
      if yaml.respond_to?( :with_indifference_access )
        yaml = yaml.with_indifferent_access
      end

      yaml[Yell.env] || {}
    end

  end
end


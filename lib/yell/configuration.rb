# frozen_string_literal: true

require 'erb'
require 'yaml'

module Yell # :nodoc:
  # The Configuration can be used to setup Yell before
  # initializing an instance.
  class Configuration
    def self.load!(file)
      yaml = YAML.load(ERB.new(File.read(file)).result)

      # in case we have ActiveSupport
      yaml = ActiveSupport::HashWithIndifferentAccess.new(yaml) if defined?(ActiveSupport::HashWithIndifferentAccess)

      yaml[Yell.env] || {}
    end
  end
end

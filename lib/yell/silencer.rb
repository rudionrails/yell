# frozen_string_literal: true

module Yell # :nodoc:
  # The +Yell::Silencer+ is your handly helper for stiping out unwanted log messages.
  class Silencer
    class PresetNotFound < StandardError # :nodoc:
      def message = "Could not find a preset for #{super.inspect}"
    end

    PRESETS = {
      assets: [%r{\AStarted GET "/assets}, /\AServed asset/, /\A\s*\z/] # for Rails
    }.freeze

    def initialize(*patterns)
      @patterns = patterns.dup
    end

    # Add one or more patterns to the silencer
    #
    # @example
    #   add( 'password' )
    #   add( 'username', 'password' )
    #
    # @example Add regular expressions
    #   add( /password/ )
    #
    # @return [self] The silencer instance
    def add(*patterns)
      patterns.each { |pattern| add!(pattern) }

      self
    end

    # Clears out all the messages that would match any defined pattern
    #
    # @example
    #   call(['username', 'password'])
    #   #=> ['username]
    #
    # @return [Array] The remaining messages
    def call(*messages)
      return messages if @patterns.empty?

      messages.reject { |m| matches?(m) }
    end

    # Get a pretty string
    def inspect
      "#<#{self.class.name} patterns: #{@patterns.inspect}>"
    end

    # @private
    attr_reader :patterns

    private

    def add!(pattern)
      @patterns |= fetch(pattern)
    end

    def fetch(pattern)
      case pattern
      when Symbol then PRESETS[pattern] or raise(PresetNotFound, pattern)
      else [pattern]
      end
    end

    # Check if the provided message matches any of the defined patterns.
    #
    # @example
    #   matches?('password')
    #   #=> true
    #
    # @return [Boolean] true or false
    def matches?(message)
      @patterns.any? { |pattern| message.respond_to?(:match) && message.match(pattern) }
    end
  end
end

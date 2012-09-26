# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    class Io < Yell::Adapters::Base
      include Yell::Formatter::Helpers

      # The possible unix log colors
      Colors = {
        0   => "\e[32;1m",  # green;bold
        # 1   => "\e[0m",     # white
        2   => "\e[33;1m",  # yello;bold
        3   => "\e[31;1m",  # red;bold
        4   => "\e[35;1m",  # magenta;bold
        5   => "\e[36m",    # cyan
        -1  => "\e[0m"      # NONE
      }

      setup do |options|
        @stream = nil

        self.colors = options.fetch(:colors, false)
        self.format = options.fetch(:format, nil)
      end

      write do |event|
        message = format.format(event)

        # colorize if applicable
        if colors and color = Colors[event.level]
          message = color + message + Colors[-1]
        end

        # add new line if there is none
        message << "\n" unless message[-1] == ?\n

        stream.write( message )
      end

      close do
        @stream.close if @stream.respond_to? :close
        @stream = nil
      end


      # Sets colored output on or off (default off)
      #
      # @example Enable colors
      #   colors = true
      #
      # @example Disable colors
      #   colors = false
      attr_accessor :colors

      # Shortcut to enable colors.
      #
      # @example
      #   colorize!
      def colorize!; @colors = true; end


      private

      # The IO stream
      #
      # Adapter classes should provide their own implementation 
      # of this method.
      def stream
        raise 'Not implemented'
      end
    end

  end
end


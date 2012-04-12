# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    class Io < Yell::Adapters::Base
      include Yell::Formatter::Helpers

      # The possible unix log colors
      Colors = {
        'DEBUG'   => "\e[32;1m",  # green;bold
        # 'INFO'    => "\e[0m",     # white
        'WARN'    => "\e[33;1m",  # yello;bold
        'ERROR'   => "\e[31;1m",  # red;bold
        'FATAL'   => "\e[35;1m",  # magenta;bold
        'UNKNOWN' => "\e[36m",    # cyan
        'DEFAULT' => "\e[0m"      # NONE
      }

      setup do |options|
        self.colors = options[:colors]
        self.format = options[:format]
      end

      write do |event|
        message = format.format(event)

        # colorize if applicable
        if colors and color = Colors[event.level]
          message = color + message + Colors['DEFAULT']
        end

        message << "\n" unless message[-1] == ?\n # add new line if there is none

        stream.print( message )
        stream.flush
      end

      close do
        @stream.close if @stream.respond_to? :close
        @stream = nil
      end


      attr_accessor :colors

      # Shortcut to enable colors
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


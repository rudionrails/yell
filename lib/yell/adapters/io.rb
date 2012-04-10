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

      attr_accessor :colors

      def initialize( options = {}, &block )
        self.colors = options[:colors]
        self.format = options[:format]

        super( options, &block )
      end

      # The IO stream
      #
      # Adapter classes should provide their own implementation 
      # of this method.
      def stream
        raise 'Not implemented'
      end

      # Close the io stream
      def close
        @stream.close if @stream.respond_to? :close

        @stream = nil
      end

      # Shortcut to enable colors
      def colorize!; @colors = true; end

      private

      # The method formats the message and writes it to the file handle.
      def write!( event )
        message = @format.format( event )

        # colorize if applicable
        if colors and color = Colors[event.level]
          message = color + message + Colors['DEFAULT']
        end

        message << "\n" unless message[-1] == ?\n # add new line if there is none

        stream.print( message )
        stream.flush
      # rescue Exception => e
      #   close

      #   # re-raise the exception
      #   raise( e, caller )
      end

    end

  end
end


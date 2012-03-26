module Yell
  module Adapters

    class Io < Yell::Adapters::Base

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


      def initialize( options = {}, &block )
        format options[:format]
        colorize options.fetch(:colorize, false)

        super
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

      # Set the format for your message.
      def format( pattern, date_pattern = nil )
        @formatter = case pattern
          when Yell::Formatter then pattern
          when false then Yell::Formatter.new( "%m" )
          else Yell::Formatter.new( pattern, date_pattern )
        end
      end

      # Enable colorizing the log output.
      def colorize( color = true )
        @colorize = color
      end


      private

      # The method formats the message and writes it to the file handle.
      def write!( event )
        message = @formatter.format( event )

        # colorize if applicable
        if colorize? and color = Colors[event.level]
          message = color + message + Colors['DEFAULT']
        end

        message << "\n" unless message[-1] == ?\n # add new line if there is none

        stream.print( message )
        stream.flush
      rescue Exception => e
        close

        # re-raise the exception
        raise( e, caller )
      end

      # Determie whether to colorize the log output or nor
      def colorize?; !!@colorize; end

    end

  end
end


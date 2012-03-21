module Yell
  module Adapters

    class Io
      include Yell::Adapters::Base

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

      # Accessor to the io stream
      attr_reader :stream


      def initialize( stream, options = {}, &block )
        @stream   = stream
        @options  = options

        level options.fetch(:level, nil)
        format options.fetch(:format, nil)
        colorize! options.fetch(:colorize, false)

        instance_eval &block if block
      end

      # Main method to calling the file adapter.
      #
      # The method formats the message and writes it to the file handle.
      #
      # @example
      #   write( 'info', 'Hello World' )
      def write( event )
        message = @formatter.format( event )

        # colorize if applicable
        if colorize? and color = Colors[level]
          message = color + message + Colors['DEFAULT']
        end

        message << "\n" unless message[-1] == ?\n # add new line if there is none

        write!( message )
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
      def colorize!( color = true )
        @colorize = color
      end

      # Determie whether to colorize the log output or nor
      #
      # @return [Boolean] true or false
      def colorize?; !!@colorize; end


      private

      # TODO: Implement Buffer to not flush immediately.
      def write!( message )
        stream.print( message )
        stream.flush
      rescue => e
        close

        # re-raise the exception
        raise( e, caller )
      end

    end

  end
end


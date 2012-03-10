# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    class Io < Yell::Adapters::Base #:nodoc:

      def initialize( handle, options = {}, &block )
        @handle   = handle
        @colorize = false

        format options[:format]
        colorize! if options[:colorize]

        super( options, &block )
      end

      # Main method to calling the file adapter.
      #
      # The method formats the message and writes it to the file handle.
      def call( *args )
        super

        msg = @formatter.format( level, message )

        # colorize if applicable
        if @colorize and color = Yell::Logger::Colors[level]
          color + msg + Yell::Logger::Colors['default']
        end

        msg << "\n" unless msg[-1] == ?\n # add new line if there is none

        write( msg )
      end

      # Set the format for your message.
      def format( pattern, date_pattern = nil )
        @formatter = case pattern
          when Yell::Formatter then pattern
          when false then Yell::Formatter.new( "%m" )
          else Yell::Formatter.new( pattern, date_pattern )
        end
      end

      # Enable colorizing the log output
      def colorize!
        @colorize = true
      end


      private

      # @override Writes the message to the file.
      def write( message )
        @handle.write( message )
        @handle.flush
      rescue => e
        close # make sure the file gets closed and the re-raise the exception

        raise( e, caller )
      end

      # @override Close the handle
      def close!
        @handle.close
      end

      # @override Open the handle
      def open!
        @handle.open
      end

      # @override Check if the handle is closed
      def closed?
        @handle.nil? or @handle.closed?
      end

    end

  end
end


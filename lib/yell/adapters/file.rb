# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # The +File+ adapter is the most basic. As one would expect, it's used 
    # for logging into files.
    class File
      include Yell::Adapters::Base

      # The possible log colors
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
        build!( options )

        instance_eval &block if block

        reset!
      end

      # @override Lazily open the file handle
      def handle
        @handle ||= ::File.open( @filename, ::File::WRONLY|::File::APPEND|::File::CREAT )
      end

      # Main method to calling the file adapter.
      #
      # The method formats the message and writes it to the file handle.
      def write( level, message )
        msg = @formatter.format( level, message )

        # colorize if applicable
        if @colorize and color = Colors[level]
          color + msg + Colors['default']
        end

        msg << "\n" unless msg[-1] == ?\n # add new line if there is none

        write!( msg )
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

      def build!( options )
        @colorize = false
        @filename = options[:filename] || default_filename

        format options[:format]
        colorize! if options[:colorize]
      end

      def default_filename
        ::File.directory?("log") ? "log/#{Yell.env}.log" : "#{Yell.env}.log"
      end

    end

  end
end


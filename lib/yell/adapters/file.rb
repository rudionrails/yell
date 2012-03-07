# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # The +File+ adapter is the most basic. As one would expect, it's used 
    # for logging into files.
    class File < Yell::Adapters::Base

      Colors = {
        'debug'   => "\e[32;1m",  # green;bold
        # 'info'    => "\e[0m",     # white
        'warn'    => "\e[33;1m",  # yello;bold
        'error'   => "\e[31;1m",  # red;bold
        'fatal'   => "\e[35;1m",  # magenta;bold
        'unknown' => "\e[36m",    # cyan
        'default' => "\e[0m"      # NONE
      }

      def initialize( options = {} )
        @handle   = nil
        @filename = options[:filename] || default_filename

        @formatter = formatter_from( options )
        @colorize  = options[:colorize]

        super
      end

      # Main method to calling the file adapter.
      #
      # The method formats the message and writes it to the file handle.
      def call( level, message )
        return unless super(level, message)

        msg = @formatter.format( level, self.message )
        msg = colorize( level, msg ) if @colorize
        msg << "\n" unless msg[-1] == ?\n # add new line if there is none

        write( msg )
      end


      private

      # @override Writes the message to the file.
      def write( msg )
        @handle.print( msg )
        @handle.flush
      rescue => e
        # make sure the file gets closed and the re-raise the exception
        close

        raise( e )
      end

      # @override Close a file handle
      def close!
        @handle.close
      end

      # @override Open a file handle
      def open!
        @handle = ::File.open(@filename, ::File::WRONLY|::File::APPEND|::File::CREAT)
      end

      # @override Return whether a file handle is open
      def opened?
        !@handle.nil?
      end

      # Returns the right formatter from the given options
      def formatter_from( options )
        if options.key?(:formatter)
          # this is done, so we can set :formatter => false to just output the given message
          options[:formatter] || Yell::Formatter.new( "%m" )
        elsif options[:formatter]
          # the options :formatter was given
          Yell::Formatter.new(
            options[:formatter][:pattern],
            options[:formatter][:date_pattern]
          )
        else
          # Standard formatter
          Yell::Formatter.new
        end
      end

      def colorize( level, msg )
        return msg unless color = Colors[level]
        color + msg + Colors['default']
      end

      def default_filename
        ::File.directory?( "log" ) ? "log/#{Yell.env}.log" : "#{Yell.env}.log"
      end

    end

  end
end

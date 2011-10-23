module Yell::Adapters
  class File < Yell::Adapters::Base

    Colors = {
      'DEBUG'   => "\e[32;1m",  # green;bold
#        'INFO'    => "\e[0m",     # white
      'WARN'    => "\e[33;1m",  # yello;bold
      'ERROR'   => "\e[31;1m",  # red;bold
      'FATAL'   => "\e[35;1m",  # magenta;bold
      'UNKNOWN' => "\e[36m",    # cyan
      'DEFAULT' => "\e[0m"      # NONE
    }

    def initialize ( options = {}, &block )
      super

      @formatter = formatter_from( options )

      @colorize = options[:colorize]
      @filename = options[:filename] || default_filename

      @file_prefix, @file_suffix = options[:file_prefix], options[:file_suffix]

      # validate the filename
      unless @filename.is_a?( String )
        raise( TypeError, "Argument :filename must be a string." )
      end
    end

    def call ( level, msg )
      super # Base call

      msg = @formatter.format( @level, message )
      msg = colorize( @level, msg ) if @colorize
      msg << "\n" unless msg[-1] == ?\n # add new line if there is none

      write( msg )
    end


    private

    def write ( msg )
      @file.print( msg )
      @file.flush
    rescue Exception => e
      close # make sure the file gets closed
      raise( e ) # re-raise the error
    end

    def close!
      @file.close
      @file = nil
    end

    def open!
      # create directory if not exists
      dirname = ::File.dirname( @filename )
      FileUtils.mkdir_p( dirname ) unless ::File.directory?( dirname )

      # open file for appending if exists, or create a new
      filename = [ dirname, "#{@file_prefix}#{::File.basename(@filename)}#{@file_suffix}" ].join( '/' )
      @file = ::File.open( filename, ::File::WRONLY|::File::APPEND|::File::CREAT )
    end

    def opened?; !@file.nil?; end

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
      return msg unless color = Colors[level.upcase]
      color + msg + Colors['DEFAULT']
    end

    def default_filename
      "#{Yell.config.env}.log"
    end

  end
end

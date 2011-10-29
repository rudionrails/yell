module Yell::Adapters
  class File < Yell::Adapters::Base

    Colors = {
      'debug'   => "\e[32;1m",  # green;bold
#        'info'    => "\e[0m",     # white
      'warn'    => "\e[33;1m",  # yello;bold
      'error'   => "\e[31;1m",  # red;bold
      'fatal'   => "\e[35;1m",  # magenta;bold
      'unknown' => "\e[36m",    # cyan
      'default' => "\e[0m"      # NONE
    }

    def initialize ( options = {}, &block )
      @handles   = {} # the possible file handles
      @filenames = {} # keeps different filenames
      @filenames[:default] = options[:filename] || default_filename

      @file_prefix, @file_suffix = options[:file_prefix], options[:file_suffix]

      @formatter = formatter_from( options )
      @colorize  = options[:colorize]

      super
    end

    def call ( level, msg )
      super

      msg = @formatter.format( @level, message )
      msg = colorize( @level, msg ) if @colorize
      msg << "\n" unless msg[-1] == ?\n # add new line if there is none

      write( msg )
    end

    def level( name, filename )
      @filenames[ name.to_s ] = filename
    end


    private

    def write( msg )
      handle = @handles[ @level ] || @handles[ :default ]

      handle.print( msg )
      handle.flush
    rescue Exception => e
      close # make sure the file gets closed
      raise( e ) # re-raise the error
    end

    def close!
      @handles.values.each( &:close )
      @handles.clear # empty the hash
    end

    def open!
      @filenames.each do |handle, filename|
        dirname  = ::File.dirname( filename )
        filename = ::File.join( dirname, "#{@file_prefix}#{::File.basename(filename)}#{@file_suffix}" )

        @handles[handle] = ::File.open( filename, ::File::WRONLY|::File::APPEND|::File::CREAT )
      end
    end

    def opened?
      @handles.any? 
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

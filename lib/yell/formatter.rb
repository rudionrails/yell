# encoding: utf-8

require 'time'

module Yell #:nodoc:

  # No format on the log message
  #
  # @example
  #   logger = Yell.new STDOUT, :format => false
  #   logger.info "Hello World!"
  #   #=> "Hello World!"
  NoFormat = "%m"

  # Default Format
  #
  # @example
  #   logger = Yell.new STDOUT, :format => Yell::DefaultFormat
  #   logger.info "Hello World!"
  #   #=> "2012-02-29T09:30:00+01:00 [ INFO] 65784 : Hello World!"
  #   #    ^                         ^       ^       ^
  #   #    ISO8601 Timestamp         Level   Pid     Message
  DefaultFormat = "%d [%5L] %p : %m"

  # Basic Format
  #
  # @example
  #   logger = Yell.new STDOUT, :format => Yell::BasicFormat
  #   logger.info "Hello World!"
  #   #=> "I, 2012-02-29T09:30:00+01:00 : Hello World!"
  #   #    ^  ^                          ^
  #   #    ^  ISO8601 Timestamp          Message
  #   #    Level (short)
  BasicFormat = "%l, %d : %m"

  # Extended Format
  #
  # @example
  #   logger = Yell.new STDOUT, :format => Yell::ExtendedFormat
  #   logger.info "Hello World!"
  #   #=> "2012-02-29T09:30:00+01:00 [ INFO] 65784 localhost : Hello World!"
  #   #    ^                          ^      ^     ^           ^
  #   #    ISO8601 Timestamp          Level  Pid   Hostname    Message
  ExtendedFormat  = "%d [%5L] %p %h : %m"


  # The +Formatter+ provides a handle to configure your log message style.
  class Formatter
    module Helpers
      # Accessor to the format
      attr_reader :format

      # Set the format for your message.
      def format=( pattern )
        @format = case pattern
          when Yell::Formatter then pattern
          when false then Yell::Formatter.new( Yell::NoFormat )
          else Yell::Formatter.new( *pattern )
        end
      end
    end

    PatternTable = {
      "m" => "message(event.message)",     # Message
      "o" => "message(event.options)",     # Message options
      "l" => "level(event.level)[0,1]",    # Level (short), e.g.'I', 'W'
      "L" => "level(event.level)",         # Level, e.g. 'INFO', 'WARN'
      "d" => "date(event.time)",           # ISO8601 Timestamp
      "h" => "event.hostname",             # Hostname
      "p" => "event.pid",                  # PID
      "t" => "event.thread_id",            # Thread ID
      "F" => "event.file",                 # Path with filename where the logger was called
      "f" => "File.basename(event.file)",  # Filename where the loger was called
      "M" => "event.method",               # Method name where the logger was called
      "n" => "event.line"                  # Line where the logger was called
    }

    PatternRegexp = /([^%]*)(%\d*)?(#{PatternTable.keys.join('|')})?(.*)/


    # Initializes a new +Yell::Formatter+.
    #
    # Upon initialization it defines a format method. `format` takes 
    # a {Yell::Event} instance as agument in order to apply for desired log 
    # message formatting.
    def initialize( pattern = nil, date_pattern = nil )
      @pattern      = pattern || Yell::DefaultFormat
      @date_pattern = date_pattern

      define!
    end


    private

    # defines the format method
    def define!
      buff, args, _pattern = "", [], @pattern.dup

      while true
        match = PatternRegexp.match( _pattern )

        buff << match[1] unless match[1].empty?
        break if match[2].nil?

        buff << match[2] + 's'
        args << PatternTable[ match[3] ]

        _pattern = match[4]
      end

      instance_eval %-
        def format( event )
          sprintf( "#{buff}", #{args.join(',')} )
        end
      -
    end

    def message( m )
      case m
        when Hash
          m.map { |k,v| "#{k}: #{v}" }.join( ", " )
        when Exception
          backtrace = m.backtrace ? "\n\t#{m.backtrace.join("\n\t")}" : ""

          "%s: %s%s" % [m.class, m.message, backtrace]
        else
          m
      end
    end

    def level( l )
      Yell::Severities[ l ]
    end

    def date( t )
      @date_pattern ? t.strftime( @date_pattern ) : t.iso8601
    end

  end
end


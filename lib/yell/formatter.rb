# encoding: utf-8

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


  def self.format( pattern, date_pattern = nil )
    Yell::Formatter.new( pattern, date_pattern )
  end


  # The +Formatter+ provides a handle to configure your log message style.
  class Formatter

    PatternTable = {
      "m" => "event.message",                 # Message
      "l" => "event.level[0,1]",              # Level (short), e.g.'I', 'W'
      "L" => "event.level",                   # Level, e.g. 'INFO', 'WARN'
      "d" => "date(event)",                   # ISO8601 Timestamp
      "p" => "Process.pid",                   # PID
      "h" => "hostname",                      # Hostname
      "F" => "event.file",                    # Path with filename where the logger was called
      "f" => "File.basename(event.file)",     # Filename where the loger was called
      "M" => "event.method",                  # Method name where the logger was called
      "n" => "event.line"                     # Line where the logger was called
    }

    PatternRegexp = /([^%]*)(%\d*)?([#{PatternTable.keys.join}])?(.*)/


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

        buff << match[2] + 's' # '%s'
        args << PatternTable[ match[3] ]

        _pattern = match[4]
      end

      instance_eval %-
        def format( event )
          sprintf( "#{buff}", #{args.join(',')} )
        end
      -
    end

    def date( event )
      @date_pattern ? event.time.strftime( @date_pattern ) : event.time.iso8601
    end

    def hostname
      require 'socket' unless defined? Socket

      Socket.gethostname rescue nil
    end

  end
end


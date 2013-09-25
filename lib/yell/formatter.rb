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

    Table = {
      "m" => "message(*event.messages)",   # Message
      "l" => "level(event.level)[0,1]",    # Level (short), e.g.'I', 'W'
      "L" => "level(event.level)",         # Level, e.g. 'INFO', 'WARN'
      "d" => "date(event.time)",           # ISO8601 Timestamp
      "h" => "event.hostname",             # Hostname
      "p" => "event.pid",                  # PID
      "P" => "event.progname",             # Progname
      "t" => "event.thread_id",            # Thread ID
      "F" => "event.file",                 # Path with filename where the logger was called
      "f" => "File.basename(event.file)",  # Filename where the loger was called
      "M" => "event.method",               # Method name where the logger was called
      "n" => "event.line",                 # Line where the logger was called
      "N" => "event.name"                  # Name of the logger
    }

    Matcher = /([^%]*)(%\d*)?(#{Table.keys.join('|')})?(.*)/


    # Initializes a new +Yell::Formatter+.
    #
    # Upon initialization it defines a format method. `format` takes
    # a {Yell::Event} instance as agument in order to apply for desired log
    # message formatting.
    #
    # @example Blank formatter
    #   Formatter.new
    #
    # @example Formatter with a message pattern
    #   Formatter.new("%d [%5L] %p : %m")
    #
    # @example Formatter with a message and date pattern
    #   Formatter.new("%d [%5L] %p : %m", "%D %H:%M:%S.%L")
    #
    # @example Formatter with a message modifier
    #   Formatter.new do |f|
    #     f.modify(Hash) { |h| "Hash: #{h.inspect}" }
    #   end
    def initialize( *args, &block )
      builder = Builder.new(*args, &block)

      @pattern = builder.pattern
      @date_pattern = builder.date_pattern
      @modifier = builder.modifier

      define_date_method!
      define_format_method!
    end

    # Get a pretty string
    def inspect
      "#<#{self.class.name} pattern: #{@pattern.inspect}, date_pattern: #{@date_pattern.inspect}>"
    end


    private

    # Message modifier class to allow different modifiers for different requirements.
    class Modifier
      def initialize
        @repository = {}
      end

      def set( key, &block )
        @repository.merge!(key => block)
      end

      def call( message )
        case
        when mod = @repository[message.class] || @repository[message.class.to_s]
          mod.call(message)
        when message.is_a?(Hash)
          message.map { |k,v| "#{k}: #{v}" }.join(", ")
        when message.is_a?(Exception)
          backtrace = message.backtrace ? "\n\t#{message.backtrace.join("\n\t")}" : ""
          sprintf("%s: %s%s", message.class, message.message, backtrace)
        else
          message
        end
      end
    end

    # Builder class to allow setters that won't be accessible once
    # transferred to the Formatter
    class Builder
      attr_accessor :pattern, :date_pattern
      attr_reader :modifier

      def initialize( pattern = nil, date_pattern = nil, &block )
        @modifier = Modifier.new

        @pattern = pattern || Yell::DefaultFormat
        @date_pattern = date_pattern || :iso8601

        block.call(self) if block
      end

      def modify( key, &block )
        modifier.set(key, &block)
      end
    end

    def define_date_method!
      buf = case @date_pattern
      when String then "t.strftime(@date_pattern)"
      when Symbol then respond_to?(@date_pattern, true) ? "#{@date_pattern}(t)" : "t.#{@date_pattern}"
      else "iso8601(t)"
      end

      instance_eval %-
        def date( t )
          #{buf}
        end
      -
    end

    def define_format_method!
      buff, args, _pattern = "", [], @pattern.dup

      while true
        match = Matcher.match(_pattern)

        buff << match[1] unless match[1].empty?
        break if match[2].nil?

        buff << match[2] + 's'
        args << Table[ match[3] ]

        _pattern = match[4]
      end

      instance_eval <<-EOS, __FILE__, __LINE__
        def format( event )
          sprintf("#{buff}", #{args.join(',')})
        end
      EOS
    end

    # The iso8601 implementation of the standard Time library is more than
    # twice as slow compared to using strftime. So, we just implement
    # it ourselves --R
    def iso8601( t )
      zone = if t.utc?
        "-00:00"
      else
        offset = t.utc_offset
        sign = offset < 0 ? '-' : '+'
        sprintf('%s%02d:%02d', sign, *(offset.abs/60).divmod(60))
      end

      t.strftime("%Y-%m-%dT%H:%M:%S#{zone}")
    end

    def level( l )
      Yell::Severities[ l ]
    end

    def message( *messages )
      messages.map { |m| @modifier.call(m) }.join(" ")
    end

  end
end


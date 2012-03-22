module Yell #:nodoc:

  class Event
    CallerRegexp = /^(.+?):(\d+)(?::in `(.*)')?/

    # Accessor to the log level
    attr_reader :level

    # Accessor to the log message
    attr_reader :message

    # Accessor to the time the log event occured
    attr_reader :time

    # Accessor to filename the log event occured
    attr_reader :file

    # Accessor to the line the log event occured
    attr_reader :line

    # Accessor to the method the log event occured
    attr_reader :method


    # Initialize a new log event
    def initialize( level, message = nil, &block )
      @time     = Time.now
      @level    = level
      @message  = block ? block.call : message

      if m = CallerRegexp.match( caller(4).first )
        @file, @line, @method = m[1..-1]
      else
        @file, @line, @method = ['', '', '']
      end
    end

  end
end


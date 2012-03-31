# encoding: utf-8

module Yell #:nodoc:

  class Event
    CallerRegexp = /^(.+?):(\d+)(?::in `(.+)')?/

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

    # Accessor to the hostname
    attr_reader :hostname

    # Accessor to the pid
    attr_reader :pid

    # Accessor to the current tread_id
    attr_reader :thread_id


    def initialize( level, message = nil, &block )
      @time     = Time.now
      @level    = level
      @message  = block ? block.call : message

      @hostname   = Socket.gethostname rescue nil
      @pid        = Process.pid
      @thread_id  = Thread.current.object_id

      _initialize_caller
    end


    private

    def _initialize_caller
      if m = CallerRegexp.match( caller(4).first )
        @file, @line, @method = m[1..-1]
      else
        @file, @line, @method = ['', '', '']
      end
    end

  end
end


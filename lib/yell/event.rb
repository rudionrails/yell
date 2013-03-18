# encoding: utf-8

require 'time'
require 'socket'

module Yell #:nodoc:

  # Yell::Event.new( :info, 'Hello World', { :scope => 'Application' } )
  # #=> Hello World scope: Application
  class Event
    # regex to fetch caller attributes
    CallerRegexp = /^(.+?):(\d+)(?::in `(.+)')?/

    # jruby and rubinius seem to have a different caller
    CallerIndex = defined?(RUBY_ENGINE) && ["rbx", "jruby"].include?(RUBY_ENGINE) ? 1 : 2

    # Prefetch those values (no need to do that on every new instance)
    @@hostname  = Socket.gethostname rescue nil
    @@progname  = $0

    # Accessor to the log level
    attr_reader :level

    # Accessor to the log messages
    attr_reader :messages

    # Accessor to the time the log event occured
    attr_reader :time


    def initialize(logger, level, *messages, &block)
      @time     = Time.now
      @level    = level

      @messages = messages
      @messages << block.call if block

      @caller = logger.trace.at?(level) ? caller[CallerIndex].to_s : ''
      @file   = nil
      @line   = nil
      @method = nil

      @pid = nil
    end

    # Accessor to the hostname
    def hostname
      @@hostname
    end

    # Accessor to the progname
    def progname
      @@progname
    end

    # Accessor to the PID
    def pid
      Process.pid
    end

    # Accessor to the thread's id
    def thread_id
      Thread.current.object_id
    end

    # Accessor to filename the log event occured
    def file
      @file || (backtrace!; @file)
    end

    # Accessor to the line the log event occured
    def line
      @line || (backtrace!; @line)
    end

    # Accessor to the method the log event occured
    def method
      @method || (backtrace!; @method)
    end


    private

    def backtrace!
      if m = CallerRegexp.match(@caller)
        @file, @line, @method = m[1..-1]
      else
        @file, @line, @method = ['', '', '']
      end
    end

  end
end


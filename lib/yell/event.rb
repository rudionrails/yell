# encoding: utf-8

require 'time'
require 'socket'

module Yell #:nodoc:

  class Event
    # regex to fetch caller attributes
    @@caller_regexp = /^(.+?):(\d+)(?::in `(.+)')?/

    # jruby and rubinius seemsto have a different caller
    @@caller_index = 2
    if defined?(RUBY_ENGINE) and ["rbx", "jruby"].include?(RUBY_ENGINE)
      @@caller_index =1
    end

    # Prefetch those values (no need to do that on every new instance)
    @@hostname  = Socket.gethostname rescue nil
    @@pid       = Process.pid

    # Accessor to the log level
    attr_reader :level

    # Accessor to the log message
    attr_reader :message

    # Accessor to the time the log event occured
    attr_reader :time

    # Accessor to the current tread_id
    attr_reader :thread_id


    def initialize( level, message = nil, &block )
      @time     = Time.now
      @level    = level
      @message  = block ? block.call : message

      @thread_id  = Thread.current.object_id

      @caller = caller[@@caller_index].to_s
      @file   = nil
      @line   = nil
      @method = nil
    end

    # Accessor to the pid
    def hostname
      @@hostname
    end

    # Accessor to the hostname
    def pid
      @@pid
    end

    # Accessor to filename the log event occured
    def file
      _caller! if @file.nil?
      @file
    end

    # Accessor to the line the log event occured
    def line
      _caller! if @line.nil?
      @line
    end

    # Accessor to the method the log event occured
    def method
      _caller! if @method.nil?
      @method
    end


    private

    def _caller!
      if m = @@caller_regexp.match( @caller )
        @file, @line, @method = m[1..-1]
      else
        @file, @line, @method = ['', '', '']
      end
    end

  end
end


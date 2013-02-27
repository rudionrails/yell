# encoding: utf-8

require 'pathname'

module Yell #:nodoc:

  # The +Yell::Logger+ is your entrypoint. Anything onwards is derived from here.
  #
  # A +Yell::Logger+ instance holds all your adapters and sends the log events 
  # to them if applicable. There are multiple ways of how to create a new logger.
  class Logger
    include Yell::Level::Helpers

    # The name of the logger instance
    attr_reader :name

    # Stacktrace or not
    attr_reader :trace

    # Initialize a new Logger
    #
    # @example A standard file logger
    #   Yell::Logger.new 'development.log'
    #
    # @example A standard datefile logger
    #   Yell::Logger.new :datefile
    #   Yell::Logger.new :datefile, 'development.log'
    #
    # @example Setting the log level
    #   Yell::Logger.new :level => :warn
    #
    #   Yell::Logger.new do |l|
    #     l.level = :warn
    #   end
    #
    # @example Combined settings
    #   Yell::Logger.new 'development.log', :level => :warn
    #
    #   Yell::Logger.new :datefile, 'development.log' do |l|
    #     l.level = :info
    #   end
    def initialize( *args, &block )
      @adapters = []

      # extract options
      @options = args.last.is_a?(Hash) ? args.pop : {}

      # adapters may be passed in the options
      extract!(@options)

      # check if filename was given as argument and put it into the @options
      if [String, Pathname].include?(args.last.class)
        @options[:filename] = args.pop unless @options[:filename]
      end

      self.level = @options.fetch(:level, 0) # debug by defauly
      self.name = @options.fetch(:name, nil) # no name by default
      self.trace = @options.fetch(:trace, :error) # trace from :error level onwards

      # extract adapter
      self.adapter(args.pop) if args.any?

      # eval the given block
      block.arity > 0 ? block.call(self) : instance_eval(&block) if block_given?

      # default adapter when none defined
      self.adapter(:file) if @adapters.empty?
    end


    # Set the name of a logger. When providing a name, the logger will
    # automatically be added to the Yell::Repository.
    #
    # @return [String] The logger's name
    def name=( val )
      @name = val
      Yell::Repository[@name] = self if @name

      @name
    end

    # Set whether the logger should allow tracing or not. The trace option
    # will tell the logger when to provider caller information.
    #
    # @example No tracing at all
    #   trace = false
    #
    # @example Trace every time
    #   race = true
    #
    # @example Trace from the error level onwards
    #   trace = :error
    #   trace = 'gte.error'
    #
    # @return [Yell::Level] a level representation of the tracer
    def trace=( severity )
      @trace = case severity
      when true then Yell::Level.new
      when false then Yell::Level.new( "gt.#{Yell::Severities.last}" )
      when Yell::Level then severity
      else Yell::Level.new( severity )
      end
    end

    # Define an adapter to be used for logging.
    #
    # @example Standard adapter
    #   adapter :file
    #
    # @example Standard adapter with filename
    #   adapter :file, 'development.log'
    #
    #   # Alternative notation for filename in options
    #   adapter :file, :filename => 'developent.log'
    #
    # @example Standard adapter with filename and additional options
    #   adapter :file, 'development.log', :level => :warn
    #
    # @example Set the adapter directly from an adapter instance
    #   adapter( Yell::Adapter::File.new )
    #
    # @param [Symbol] type The type of the adapter, may be `:file` or `:datefile` (default `:file`)
    # @return [Yell::Adapter] The instance
    # @raise [Yell::NoSuchAdapter] Will be thrown when the adapter is not defined
    def adapter( type = :file, *args, &block )
      options = [@options, *args].inject( Hash.new ) do |h, c|
        h.merge( [String, Pathname].include?(c.class) ? {:filename => c} : c  )
      end

      @adapters << Yell::Adapters.new( type, options, &block )
    end

    # Creates instance methods for every log level:
    #   `debug` and `debug?`
    #   `info` and `info?`
    #   `warn` and `warn?`
    #   `error` and `error?`
    #   `unknown` and `unknown?`
    Yell::Severities.each_with_index do |s, index|
      name = s.downcase

      class_eval <<-EOS, __FILE__, __LINE__
        def #{name}?; @level.at?(#{index}); end         # def info?; @level.at?(1); end
                                                        #
        def #{name}( *m, &b )                           # def info( *m, &b )
          return false unless #{name}?                  #   return false unless info?
          write Yell::Event.new(self, #{index}, *m, &b) #   write Yell::Event.new(self, 1, *m, &b)
                                                        #
          true                                          #   true
        end                                             # end
      EOS
    end

    # Get a pretty string representation of the logger.
    def inspect
      inspection = inspectables.inject( [] ) { |r, c| r << "#{c}: #{send(c).inspect}" }
      "#<#{self.class.name} #{inspection * ', '}, adapters: #{@adapters.map(&:inspect) * ', '}>"
    end

    # @private
    def close
      @adapters.each(&:close)
    end

    # @private
    def adapters
      @adapters
    end

    private

    # The :adapters key may be passed to the options hash. It may appear in
    # multiple variations:
    #
    # @example
    #   options = { :adapters => [:stdout, :stderr] }
    #
    # @example
    #   options = { :adapters => [:stdout => {:level => :info}, :stderr => {:level => :error}]
    def extract!( opts )
      ( opts.delete(:adapters) || [] ).each do |a|
        case a
        when String, Symbol then adapter( a )
        else a.each { |n, o| adapter( n, o || {} ) }
        end
      end
    end

    # Cycles all the adapters and writes the message
    def write( event )
      @adapters.each { |a| a.write(event) }
    end

    # Get an array of inspected attributes for the adapter.
    def inspectables
      [ :name, :level, :trace ]
    end

  end
end


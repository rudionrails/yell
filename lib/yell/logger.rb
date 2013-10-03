# encoding: utf-8

require 'pathname'

module Yell #:nodoc:

  # The +Yell::Logger+ is your entrypoint. Anything onwards is derived from here.
  #
  # A +Yell::Logger+ instance holds all your adapters and sends the log events 
  # to them if applicable. There are multiple ways of how to create a new logger.
  class Logger
    include Yell::Helpers::Base
    include Yell::Helpers::Level
    include Yell::Helpers::Formatter
    include Yell::Helpers::Adapter
    include Yell::Helpers::Tracer
    include Yell::Helpers::Silencer

    # The name of the logger instance
    attr_reader :name

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
      reset!

      # extract options
      @options = args.last.is_a?(Hash) ? args.pop : {}

      # check if filename was given as argument and put it into the @options
      if [String, Pathname].include?(args.last.class)
        @options[:filename] = args.pop unless @options[:filename]
      end

      # FIXME: :format is deprecated in future versions --R
      self.formatter = @options.fetch(:format, @options.fetch(:formatter, Yell::DefaultFormat))
      self.level = @options.fetch(:level, 0)
      self.name = @options.fetch(:name, nil)
      self.trace = @options.fetch(:trace, :error)

      # silencer
      self.silence(*@options[:silence]) if @options.key?(:silence)

      # adapters may be passed in the options
      extract!(*@options[:adapters]) if @options.key?(:adapters)

      # extract adapter
      self.adapter(args.pop) if args.any?

      # eval the given block
      block.arity > 0 ? block.call(self) : instance_eval(&block) if block_given?

      # default adapter when none defined
      self.adapter(:file) if _adapter.nil?
    end


    # Set the name of a logger. When providing a name, the logger will
    # automatically be added to the Yell::Repository.
    #
    # @return [String] The logger's name
    def name=( val )
      Yell::Repository[val] = self if val
      @name = val.nil? ? "<#{self.class.name}##{object_id}>": val

      @name
    end

    # Somewhat backwards compatible method (not fully though)
    def add( severity, message, options = {}, &block )
      return false unless level.at?(severity)

      message = silencer.silence(message) if silencer.silence?
      return false if message.nil?

      event = Yell::Event.new(self, severity, message, {:caller => 0}.merge(options), &block)
      write(event)
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
        def #{name}?; level.at?(#{index}); end                        # def info?; level.at?(1); end
                                                                      #
        def #{name}( message, options = {}, &block )                  # def info( message, options = {}, &block )
          add(#{index}, message, options.merge(:caller => 1), &block) #   add(1, message, options.merge(:caller => 1), &block)
        end                                                           # end
      EOS
    end

    # Get a pretty string representation of the logger.
    def inspect
      inspection = inspectables.map { |m| "#{m}: #{send(m).inspect}" }
      "#<#{self.class.name} #{inspection * ', '}>"
    end

    # @private
    def close
      _adapter.close
    end


    private

    def write( event )
      _adapter.write(event)
      true
    end

    # The :adapters key may be passed to the options hash. It may appear in
    # multiple variations:
    #
    # @example
    #   extract!(:stdout, :stderr)
    #
    # @example
    #   extract!(:stdout => {:level => :info}, :stderr => {:level => :error})
    def extract!( *adapters )
      adapters.each do |a|
        case a
        when Hash then a.each { |t, o| adapter(t, o) }
        else adapter(a)
        end
      end
    end

    # Get an array of inspected attributes for the adapter.
    def inspectables
      [:name] | super
    end

  end
end


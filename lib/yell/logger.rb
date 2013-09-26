# encoding: utf-8

require 'pathname'

# TODO: DSL improvements
#
# Initlalize an empty logger
#   logger = Yell.new(adapters: false)
#   logger.adapters.add :stdout
#
# Or shorthand for adapters.add
#   logger.add :stdout
#
# Or with a block
#   logger = Yell.new do |l|
#     l.add :stdout
#     l.add :stderr
#   end
#
#  logger = Yell.new do |l|
#    l.adapters.add :stdout
#    l.adapters.add :stderr
#  end
#
#
# Define Silencers
#   logger = Yell.new do |l|
#     l.silence /password/
#   end
#
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

      # adapters may be passed in the options
      extract!(*@options[:adapters]) if @options.key?(:adapters)

      # check if filename was given as argument and put it into the @options
      if [String, Pathname].include?(args.last.class)
        @options[:filename] = args.pop unless @options[:filename]
      end

      self.level = @options.fetch(:level, 0) # debug by default
      self.name = @options.fetch(:name, nil) # no name by default
      self.trace = @options.fetch(:trace, :error) # trace from :error level onwards

      # silencer
      self.silence(*@options[:silence])

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
      @name = val
      Yell::Repository[@name] = self if @name

      @name
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
        def #{name}?; level.at?(#{index}); end            # def info?; level.at?(1); end
                                                          #
        def #{name}( *m, &b )                             # def info( *m, &b )
          return false unless #{name}?                    #   return false unless info?
                                                          #
          m = silencer.silence(*m) if silencer.silence?   #   m = silencer.silence(*m) if silencer.silence?
          return false if m.empty?                        #   return false if m.empty?
                                                          #
          event = Yell::Event.new(self, #{index}, *m, &b) #   event = Yell::Event.new(self, 1, *m, &b)
          write(event)                                    #   write(event)
          true                                            #   true
        end                                               # end
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

    # Cycles all the adapters and writes the message
    def write( event )
      _adapter.write(event)
    end

    # Get an array of inspected attributes for the adapter.
    def inspectables
      [:name] | super
    end

  end
end


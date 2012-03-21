# encoding: utf-8

module Yell #:nodoc:

  # The +Logger+ is your entrypoint. Anything onwards is derived from here.
  class Logger
    # Creates a new Logger instance
    #
    # @example A standard file logger
    #   Yell::Logger.new
    #   Yell::Logger.new 'development.log'
    #
    # @example A standard datefile logger
    #   Yell::Logger.new :datefile
    #   Yell::Logger.new :datefile, 'development.log'
    #
    # @example Setting the log level
    #   Yell::Logger.new :level => :warn
    #
    #   Yell::Logger.new do
    #     level :warn
    #   end
    #
    # @example Combined settings
    #   Yell::Logger.new 'development.log', :level => :warn
    #
    #   Yell::Logger.new :datefile, 'development.log' do
    #     level :info
    #   end
    def initialize( *args, &block )
      @adapters = []

      # extract options
      @options = args.last.is_a?(Hash) ? args.pop : {}

      # set the log level when given
      # level @options[:level] if @options[:level]
      level @options[:level] # default

      # check if filename was given as argument and put it into the @options
      if args.last.is_a?( String )
        @options[:filename] = args.pop unless @options[:filename]
      end

      # extract adapter
      adapter args.pop if args.any?

      # set the log level when given
      level @options[:level] if @options[:level]

      # eval the given block
      instance_eval &block if block

      define!
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
    #
    # @return A new +Yell::Adapter+ instance
    #
    # @raise [Yell::NoSuchAdapter] Will be thrown when the adapter is not defined
    def adapter( type = :file, *args, &block )
      options = [@options, *args].inject( Hash.new ) do |h,c| 
        h.merge( c.is_a?(String) ? {:filename => c} : c  )
      end

      @adapters << Yell::Adapters[ type, options, &block ]
    rescue NameError => e
      raise Yell::NoSuchAdapter, type
    end

    # Set the minimum log level.
    #
    # @example Set the level to :warn
    #   level :warn
    #
    # @param [String, Symbol, Integer] val The minimum log level
    def level( val = nil )
      @level = Yell::Level.new( val )
    end

    # Convenience method for resetting all adapters of the Logger.
    #
    # @param [Boolean] now Perform the reset immediately (default false)
    def close( now = false )
      @adapters.each(&:close)
    end


    private

    # Sets a default adapter if none was given explicitly and defines the log methods on
    # the logger instance.
    def define!
      adapter :file if @adapters.empty? # default adapter when none defined

      define_log_methods!
    end

    # Creates instance methods for every defined log level (debug, info, ...) depending
    # on whether anything should be logged upon, for instance, #info.
    def define_log_methods!
      Yell::Severities.each do |s|
        name = s.downcase

        instance_eval %-
          def #{name}?; #{@level.at?(name)}; end    # def info?; true; end
                                                    #
          def #{name}( m = nil, &b )                # def info( m = nil, &b )
            return unless #{name}?                  #   return unless info?
                                                    #
            write Yell::Event.new( '#{s}', m, &b )  #   write Yell::Event.new( "INFO", m, &b )
                                                    #
            true                                    #   true
          end                                       # end
        -
      end
    end

    # Cycles all the adapters and writes the message
    def write( event )
      @adapters.each { |a| a.write(event) if a.write?(event.level) }
    end

  end
end


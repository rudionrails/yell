module Yell
  class Logger
    Levels = [ 'debug', 'info', 'warn', 'error', 'fatal', 'unknown' ]

    # == Defining a standard logger
    #   Yell::Logger.new
    #   Yell::Logger.new 'development.log'
    #
    #   # alternate outputter
    #   Yell::Logger.new :datefile
    #   Yell::Logger.new :datefile, 'development.log'
    #
    # == Setting the Log Level
    #   Yell::Logger.new :level => :warn
    #
    #   Yell::Logger.new do
    #     level :warn
    #   end
    #
    # == Specify different file for certain log levels
    #   Yell::Logger.new do
    #     adapter :file, "standard.log" do
    #       warn "warn.log"
    #       error "error.log"
    #     end
    #   end
    def initialize( *args, &block )
      @adapters = []

      # extract options
      @options = args.last.is_a?(Hash) ? args.pop : {}
      level @options[:level] if @options[:level] # set the log level when given

      # check if filename was given as argument and put it into the @options
      if args.last.is_a?( String )
        @options[:filename] = args.pop unless @options[:filename]
      end

      @default_adapter = args.last.is_a?( Symbol ) ? args.pop : :file

      # eval the given block
      instance_eval &block  if block

      build
    end

    # === the following methods are used for the logger setup
    def adapter( type, options = {}, &block )
      @adapters << Yell::Adapters.new( type, @options.merge(options), &block )
    rescue LoadError => e
      raise Yell::NoSuchAdapter, e.message
    end

    def level( val )
      @level = case val
        when Integer then val
        when String, Symbol then Levels.index( val.to_s )
        else nil
      end
    end

    # Convenience method for resetting all adapters of the Logger.
    #
    # @param [true, false] now Perform the reset immediately? (default false)
    def reset!( now = false )
      close
      open if now
    end

    def close; @adapters.each(&:close); end
    def open; @adapters.each(&:open); end

    
    private

    def build
      adapter @default_adapter if @adapters.empty? # default adapter when none defined

      define_log_methods
    end

    def define_log_methods
      Levels.each_with_index do |name, index|
        instance_eval %-
          def #{name}?; #{@level.nil? || index >= @level}; end

          def #{name}( data = '' )
            return unless #{name}?

            data = yield if block_given?
            process( "#{name}", data )

            data
          end
        -
      end
    end

    def process ( level, data )
      @adapters.each { |a| a.call( level, data ) }
    end

  end
end

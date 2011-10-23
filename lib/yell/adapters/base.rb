module Yell::Adapters
  class Base

    attr_reader :name # name of the logger this adapter belongs to

    # Initialize a new base adapter. Other adapters should inherit from it.
    def initialize ( options = {}, &block )
      @block = block

      @name = options[:name] || Yell.config.env
      @level, @data = '', '' # default
    end

    def call ( level, msg )
      reset!(true) if reset? # connect / get a file handle or whatever

      @level, @message = level, msg

      # self.instance_eval &@block if @block
      @block.call( self ) if @block
    end

    def message
      return @message if @message.is_a?( String )

      @message.inspect
    end

    # Convenience method for resetting the processor.
    #
    # @param [true, false] now Perform the reset immediately? (default false)
    def reset!( now = false )
      close
      open if now
    end

    # Opens the logfile or connection (in case of a database adapter)
    def open
      open! unless opened?
    end

    # Closes the file handle or connection (in case of a database adapter)
    def close
      close! unless closed?
    end


    private

    def reset?; closed?; end

    # stub
    def open!
      raise "Not implemented"
    end

    def opened?; false; end

    # stub
    def close!
      raise "Not implemented"
    end

    def closed?; !opened?; end

    # stub
    def write
      raise 'Not implemented'
    end

  end
end

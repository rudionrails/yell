# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # This class provides the basic interface for all allowed 
    # operations on any adapter implementation.
    #
    # Other adapters should include it for the base methods used 
    # by the {Yell::Logger}.
    class Base

      def initialize( options = {}, &block )
        level options[:level]

        instance_eval( &block ) if block
      end

      # The main method for calling the adapter.
      #
      # The method receives the log `event` and determines whether to 
      # actually write or not.
      def write( event )
        write!( event ) if write?( event )
      end

      # Close the adapter (stream, connection, etc).
      #
      # Adapter classes should provide their own implementation 
      # of this method.
      def close
        raise 'Not implemented'
      end

      # Set the log level.
      #
      # @example Set minimum level to :info
      #   level :info
      #
      # For more examples, refer to {Yell::Level}.
      def level( severity = nil )
        @level = Yell::Level.new( severity )
      end


      private

      # The perform the actual write.
      #
      # Adapter classes should provide their own implementation 
      # of this method.
      def write!( event )
        raise 'Not implemented'
      end

      # Determine whether to write at the given severity.
      #
      # @example
      #   write? :error
      #
      # @param [String,Symbol,Integer] severity The severity to ask if to write or not.
      #
      # @return [Boolean] true or false
      def write?( event )
        @level.nil? || @level.at?( event.level )
      end

    end

  end
end


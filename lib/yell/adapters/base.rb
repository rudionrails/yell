# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # This class provides the basic interface for all allowed 
    # operations on any adapter implementation.
    #
    # Other adapters should include it for the base methods used 
    # by the {Yell::Logger}.
    module Base

      # The main method for calling the adapter.
      #
      # Adapter classes should provide their own implementation 
      # of this method.
      def write( event )
        nil
      end

      # Determine whether to write at the given severity.
      #
      # @example
      #   write? :error
      #
      # @param [String,Symbol,Integer] severity The severity to ask if to write or not.
      #
      # @return [Boolean] true or false
      def write?( severity )
        @level.nil? || @level.at?( severity )
      end

      # Close the adapter (stream, connection, etc).
      #
      # Adapter classes should provide their own implementation 
      # of this method.
      def close
        nil
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

    end

  end
end


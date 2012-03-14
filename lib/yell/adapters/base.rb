# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # This class provides the basic interface for all allowed operations 
    # on any adapter implementation.
    #
    # Other adapters should inherit from it.
    module Base

      # Accessor to the file or databse handle
      attr_reader :handle

      # Accessor for the level to be logged at
      attr_reader :level

      def level( val )
        @level = Yell::Level.new( val )
      end

      private

      # Reset the adapter.
      def reset!
        @handle.close if @handle.respond_to?(:close)
        @handle = nil
      end

      # Writes the message to the handle
      def write!( message )
        handle.write( message )
        handle.flush
      rescue => e
        reset!

        # re-raise the exception
        raise( e, caller )
      end

      def write?( level )
      end

    end

  end
end


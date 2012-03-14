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


      # Set the log level
      def level( severity = nil )
        @level = Yell::Level.new( severity )
      end

      # Determine whether to write at the given severity
      #
      # @example
      #   write? :error
      def write?( severity )
        @level.nil? || @level.at?( severity )
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

    end

  end
end


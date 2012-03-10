# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # This class provides the basic interface for all allowed operations 
    # on any adapter implementation.
    #
    # Other adapters should inherit from it.
    class Base

      # The message to log
      attr_reader :message

      # The level to be logged with
      attr_reader :level

      # Define a new adapter.
      #
      # @params [Hash] options Adapter specific optionos
      #
      # @yield The block to be evaluated by the implemented adapter
      def initialize( options = {}, &block )
        @level, @message = nil, nil # default

        instance_eval &block if block
      end

      # The main method to calling an adapter. Subclasses will have to
      # overwrite it as it only defines the basic operations.
      def call( level, message )
        @level, @message = level, message

        reset! :now if reset? # connect, get a file handle or whatever
      end

      # Convenience method for resetting the processor.
      #
      # @param [Boolean] now Perform the reset immediately (default false)
      def reset!( now = false )
        close
        open if now
      end

      # Opens the logfile or connection (in case of a database adapter)
      def open
        open! if closed?
      end

      # Closes the file handle or connection (in case of a database adapter)
      def close
        close! unless closed?
      end


      private

      # Stub method to be implemented by the adapter subclass
      def write; raise 'Not implemented'; end

      # Stub method to be implemented by the adapter subclass
      def open!; raise "Not implemented"; end

      # Stub method to be implemented by the adapter subclass
      def close!; raise "Not implemented"; end

      # Returns whether a handle is closed.
      #
      # @return [Boolean] true or false
      def closed?; true; end

      # Returns whether a handle is to be reset.
      #
      # @return [Boolean] true or false
      def reset?; closed?; end

    end

  end
end


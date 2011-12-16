# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # This class provides the basic interface for all allowed operations 
    # on any adapter implementation.
    #
    # Other adapters should inherit from it.
    class Base

      # Define a new adapter.
      #
      # @params [Hash] options Adapter specific optionos
      #
      # @yield The block to be evaluated by the implemented adapter
      def initialize( options = {}, &block )
        @level, @data = nil, nil # default
      end

      # The main method to calling an adapter. Subclasses will have to
      # overwrite it as it only defines the basic operations.
      def call( level, msg )
        @level, @message = level, msg

        reset! :now if reset? # connect, get a file handle or whatever
      end

      # The message to be logged.
      #
      # If the mssage is not a +String+ then we call `:inspect` on it.
      def message
        @message.is_a?(String) ? @message : @message.inspect
      end

      # Convenience method for resetting the processor.
      #
      # @param [Boolean] now Perform the reset immediately (default false)
      def reset!( now = false )
        close
        open if now
      end

      # Opens the logfile or connection (in case of a database adapter)
      def open; open! unless opened?; end

      # Closes the file handle or connection (in case of a database adapter)
      def close; close! unless closed?; end


      private

      # Stub method to be implemented by the adapter subclass
      def write; raise 'Not implemented'; end

      # Stub method to be implemented by the adapter subclass
      def open!; raise "Not implemented"; end

      # Stub method to be implemented by the adapter subclass
      def close!; raise "Not implemented"; end

      # Returns whether a handle is opened.
      #
      # @return [Boolean] true or false
      def opened?; false; end

      # Returns whether a handle is closed.
      #
      # @return [Boolean] true or false
      def closed?; !opened?; end

      # Returns whether a handle is to be reset.
      #
      # @return [Boolean] true or false
      def reset?; closed?; end

    end

  end
end


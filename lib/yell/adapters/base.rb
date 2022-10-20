# frozen_string_literal: true

require 'monitor'

module Yell # :nodoc:
  module Adapters # :nodoc:
    # This class provides the basic interface for all allowed operations on any
    # adapter implementation. Other adapters should inherit from it for the methods
    # used by the {Yell::Logger}.
    #
    # Writing your own adapter is really simple. Inherit from the base class and use
    # the `setup`, `write` and `close` methods. Yell requires the `write` method to be
    # specified (`setup` and `close` are optional).
    #
    #
    # The following example shows how to define a basic Adapter to format and print
    # log events to STDOUT:
    #
    #   class PutsAdapter < Yell::Adapters::Base
    #     include Yell::Formatter::Helpers
    #
    #     setup do |options|
    #       self.format = options[:format]
    #     end
    #
    #     write do |event|
    #       message = format.call(event)
    #
    #       STDOUT.puts message
    #     end
    #   end
    #
    #
    # After the Adapter has been written, we need to register it to Yell:
    #
    #   Yell::Adapters.register :puts, PutsAdapter
    #
    # Now, we can use it like so:
    #
    #   logger = Yell.new :puts
    #   logger.info "Hello World!"
    class Base < Monitor
      include Yell::Helpers::Base
      include Yell::Helpers::Level

      class << self
        # Setup your adapter with this helper method.
        #
        # @example
        #   setup do |options|
        #     @file_handle = File.new( '/dev/null', 'w' )
        #   end
        def setup(&)
          compile!(:setup!, &)
        end

        # Define your write method with this helper.
        #
        # @example Printing messages to file
        #   write do |event|
        #     @file_handle.puts event.message
        #   end
        def write(&)
          compile!(:write!, &)
        end

        # Define your open method with this helper.
        #
        # @example Open a file handle
        #   open do
        #     @stream = ::File.open( 'test.log', ::File::WRONLY|::File::APPEND|::File::CREAT )
        #   end
        def open(&)
          compile!(:open!, &)
        end

        # Define your close method with this helper.
        #
        # @example Closing a file handle
        #   close do
        #     @stream.close
        #   end
        def close(&)
          compile!(:close!, &)
        end

        private

        # Pretty funky code block, I know but here is what it basically does:
        #
        # @example
        #   compile! :write! do |event|
        #     puts event.message
        #   end
        #
        #   # Is actually defining the `:write!` instance method with a call to super:
        #
        #   def write!( event )
        #     puts event.method
        #     super
        #   end
        def compile!(name, &)
          # Get the already defined method
          original_method = instance_method(name)

          # Create a new method with leading underscore
          define_method("_#{name}", &)
          unbound_method = instance_method("_#{name}")
          remove_method("_#{name}")

          # Define instance method
          define!(name, unbound_method, original_method, &)
        end

        # Define instance method by given name and call the unbound
        # methods in order with provided block.
        def define!(name, unbound_method, original_method, &block)
          if block.arity.zero?
            define_method(name) do
              unbound_method.bind(self).call
              original_method.bind(self).call
            end
          else
            define_method(name) do |*args|
              unbound_method.bind(self).call(*args)
              original_method.bind(self).call(*args)
            end
          end
        end
      end

      # Initializes a new Adapter.
      #
      # You should not overload the constructor, use #setup instead.
      def initialize(options = {}, &block)
        super() # init the monitor superclass

        reset!
        setup!(options)

        return unless block_given?

        block.arity.positive? ? block.call(self) : instance_eval(&block)
      end

      # The main method for calling the adapter.
      #
      # The method receives the log `event` and determines whether to
      # actually write or not.
      def write(event)
        synchronize { write!(event) if write?(event) }
      rescue Exception => e
        # make sure the adapter is closed and re-raise the exception
        synchronize { close }

        raise(e)
      end

      # Close the adapter (stream, connection, etc).
      #
      # Adapter classes should provide their own implementation
      # of this method.
      def close
        close!
      end

      # Get a pretty string representation of the adapter, including
      def inspect
        inspection = inspectables.map { |m| "#{m}: #{send(m).inspect}" }
        "#<#{self.class.name} #{inspection * ', '}>"
      end

      private

      # Setup the adapter instance.
      #
      # Adapter classes should provide their own implementation
      # of this method (if applicable).
      def setup!(options)
        self.level = Yell.__fetch__(options, :level)
      end

      # Perform the actual write.
      #
      # Adapter classes must provide their own implementation
      # of this method.
      def write!(event)
        # Not implemented
      end

      # Perform the actual open.
      #
      # Adapter classes should provide their own implementation
      # of this method.
      def open!
        # Not implemented
      end

      # Perform the actual close.
      #
      # Adapter classes should provide their own implementation
      # of this method.
      def close!
        # Not implemented
      end

      # Determine whether to write at the given severity.
      #
      # @example
      #   write? Yell::Event.new( 'INFO', 'Hello Wold!' )
      #
      # @param [Yell::Event] event The log event
      #
      # @return [Boolean] true or false
      def write?(event)
        level.nil? || level.at?(event.level)
      end

      # Get an array of inspected attributes for the adapter.
      def inspectables
        [:level]
      end
    end
  end
end

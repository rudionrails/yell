# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    class Io < Yell::Adapters::Base
      include Yell::Formatter::Helpers

      # The possible unix log colors
      Colors = {
        0   => "\e[32;1m",  # green;bold
        # 1   => "\e[0m",     # white
        2   => "\e[33;1m",  # yello;bold
        3   => "\e[31;1m",  # red;bold
        4   => "\e[35;1m",  # magenta;bold
        5   => "\e[36m",    # cyan
        -1  => "\e[0m"      # NONE
      }

      # Sets the “sync mode” to true or false.
      #
      # When true (default), every log event is immediately written to the file. 
      # When false, the log event is buffered internally.
      attr_accessor :sync

      # Sets colored output on or off (default off)
      #
      # @example Enable colors
      #   colors = true
      #
      # @example Disable colors
      #   colors = false
      attr_accessor :colors

      # Shortcut to enable colors.
      #
      # @example
      #   colorize!
      def colorize!; @colors = true; end


      private

      # @overload setup!( options )
      def setup!( options )
        @stream = nil

        self.colors = options.fetch(:colors, false)
        self.format = options.fetch(:format, nil)
        self.sync = options.fetch(:sync, true)

        super
      end

      # @overload write!( event )
      def write!( event )
        message = format.format(event)

        # colorize if applicable
        if colors and color = Colors[event.level]
          message = color + message + Colors[-1]
        end

        message << "\n" unless message[-1] == ?\n
        stream.syswrite( message )

        super
      end

      # @overload open!
      def open!
        @stream.sync = self.sync if @stream.respond_to? :sync
        @stream.flush            if @stream.respond_to? :flush

        super
      end

      # @overload close!
      def close!
        @stream.close if @stream.respond_to? :close
        @stream = nil

        super
      end

      # The IO stream
      #
      # Adapter classes should provide their own implementation 
      # of this method.
      def stream
        synchronize { open! if @stream.nil?; @stream }
      end

      # @overload inspectables
      def inspectables
        super.concat [:format, :colors, :sync]
      end

    end

  end
end


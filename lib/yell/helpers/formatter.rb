# encoding: utf-8
module Yell #:nodoc:
  module Helpers #:nodoc:
    module Formatter #:nodoc:

      # Set the format for your message.
      def format=( pattern )
        @formatter = case pattern
        when Yell::Formatter then pattern
        when false then Yell::Formatter.new(Yell::NoFormat)
        else Yell::Formatter.new(*pattern)
        end
      end

      # @private
      def format
        @formatter
      end

      private

      def reset!
        @formatter = Yell::Formatter.new

        super
      end

    end
  end
end


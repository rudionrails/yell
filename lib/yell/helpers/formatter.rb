# encoding: utf-8
module Yell #:nodoc:
  module Helpers #:nodoc:
    module Formatter #:nodoc:

      # Set the format for your message.
      def formatter=( pattern )
        @formatter = case pattern
        when Yell::Formatter then pattern
        when false then Yell::Formatter.new(Yell::NoFormat)
        else Yell::Formatter.new(*pattern)
        end
      end
      alias :format= :formatter=

      # @private
      def formatter
        @formatter
      end
      alias :format :formatter


      private

      def reset!
        @formatter = Yell::Formatter.new

        super
      end

    end
  end
end


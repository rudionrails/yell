# encoding: utf-8
module Yell #:nodoc:
  module Helpers #:nodoc:
    module Level

      # Set the minimum log level.
      #
      # @example Set the level to :warn
      #   level = :warn
      #
      # @param [String, Symbol, Integer] severity The minimum log level
      def level=( severity )
        @level.set(severity)
      end

      # @private
      def level
        @level
      end


      private

      def reset!
        @level = Yell::Level.new

        super
      end

      def inspectables
        [:level] | super
      end

    end
  end
end


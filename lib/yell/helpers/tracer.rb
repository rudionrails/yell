# encoding: utf-8
module Yell #:nodoc:
  module Helpers #:nodoc:
    module Tracer #:nodoc:

      # Set whether the logger should allow tracing or not. The trace option
      # will tell the logger when to provider caller information.
      #
      # @example No tracing at all
      #   trace = false
      #
      # @example Trace every time
      #   race = true
      #
      # @example Trace from the error level onwards
      #   trace = :error
      #   trace = 'gte.error'
      #
      # @return [Yell::Level] a level representation of the tracer
      def trace=( severity )
        case severity
        when false then @tracer.set("gt.#{Yell::Severities.last}")
        else @tracer.set(severity)
        end
      end

      # @private
      def trace
        @tracer
      end


      private

      def reset!
        @tracer = Yell::Level.new

        super
      end

      def inspectables
        [:trace] | super
      end

    end
  end
end


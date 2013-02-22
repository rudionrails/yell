# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    class Stdout < Yell::Adapters::Io

      private

      # @overload open!
      def open!
        @stream = $stdout.clone
        super
      end

    end

    class Stderr < Yell::Adapters::Io

      private

      # @overload open!
      def open!
        @stream = $stderr.clone
        super
      end

    end

    register( :stdout, Yell::Adapters::Stdout )
    register( :stderr, Yell::Adapters::Stderr )

  end
end


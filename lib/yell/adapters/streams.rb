# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    class Stdout < Yell::Adapters::Io

      # @overload Lazily open the STDOUT stream
      def stream
        @stream ||= $stdout.clone
      end
    end

    class Stderr < Yell::Adapters::Io

      # @overload Lazily open the STDERR stream
      def stream
        @stream ||= $stderr.clone
      end
    end

    register( :stdout, Yell::Adapters::Stdout )
    register( :stderr, Yell::Adapters::Stderr )

  end
end


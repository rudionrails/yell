# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    class Stdout < Yell::Adapters::Io

      open do
        @stream = $stdout.clone
      end

    end

    class Stderr < Yell::Adapters::Io

      open do
        @stream = $stderr.clone
      end

    end

    register( :stdout, Yell::Adapters::Stdout )
    register( :stderr, Yell::Adapters::Stderr )

  end
end


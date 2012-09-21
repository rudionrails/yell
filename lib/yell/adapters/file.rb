# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # The +File+ adapter is the most basic. As one would expect, it's used 
    # for logging into files.
    class File < Yell::Adapters::Io

      setup do |options|
        @filename = ::File.expand_path options.fetch(:filename, default_filename)

        # sync immediately to IO (or not)
        self.sync = options.fetch(:sync, true)
      end


      # Sets the “sync mode” to true or false.
      #
      # When true (default), every log event is immediately written to the file. 
      # When false, the log event is buffered internally.
      attr_accessor :sync


      private

      # @overload Lazily open the file handle
      def stream
        synchronize { @stream or open! }
      end

      def open!
        @stream = ::File.open( @filename, ::File::WRONLY|::File::APPEND|::File::CREAT )
        @stream.sync = sync

        @stream
      end

      def default_filename #:nodoc:
        logdir = ::File.expand_path("log")

        ::File.expand_path ::File.directory?(logdir) ? "#{logdir}/#{Yell.env}.log" : "#{Yell.env}.log"
      end

    end

    register( :file, Yell::Adapters::File )

  end
end


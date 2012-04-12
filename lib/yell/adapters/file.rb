# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # The +File+ adapter is the most basic. As one would expect, it's used 
    # for logging into files.
    class File < Yell::Adapters::Io

      setup do |options|
        @filename = options.fetch(:filename, default_filename)
      end


      private

      # @overload Lazily open the file handle
      def stream
        @stream ||= ::File.open( @filename, ::File::WRONLY|::File::APPEND|::File::CREAT )
      end

      def default_filename #:nodoc:
        ::File.directory?("log") ? "log/#{Yell.env}.log" : "#{Yell.env}.log"
      end

    end

    register( :file, Yell::Adapters::File )

  end
end


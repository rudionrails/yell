# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # The +File+ adapter is the most basic. As one would expect, it's used 
    # for logging into files.
    class File < Yell::Adapters::Io

      def initialize( options = {}, &block )
        super( nil, options, &block )

        @filename = options[:filename] || default_filename
      end

      private

      # @override Open a file handle
      def open!
        @handle = ::File.open( @filename, ::File::WRONLY|::File::APPEND|::File::CREAT )
      end

      def default_filename
        ::File.directory?("log") ? "log/#{Yell.env}.log" : "#{Yell.env}.log"
      end

    end

  end
end

# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # The +File+ adapter is the most basic. As one would expect, it's used 
    # for logging into files.
    class File < Yell::Adapters::Io

      setup do |options|
        @filename = ::File.expand_path options.fetch(:filename, default_filename)
      end

      open do
        @stream = ::File.open( @filename, ::File::WRONLY|::File::APPEND|::File::CREAT )
      end


      private

      def default_filename #:nodoc:
        logdir = ::File.expand_path("log")

        ::File.expand_path ::File.directory?(logdir) ? "#{logdir}/#{Yell.env}.log" : "#{Yell.env}.log"
      end

    end

    register( :file, Yell::Adapters::File )

  end
end


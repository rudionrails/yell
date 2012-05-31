# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # The +Datefile+ adapter is similar to the +File+ adapter. However, it
    # rotates the file at midnight.
    class Datefile < Yell::Adapters::File

      # The default date pattern, e.g. "19820114" (14 Jan 1982)
      DefaultDatePattern = "%Y%m%d"


      setup do |options|
        @date = nil # default; do not override --R

        self.date_pattern = options.fetch( :date_pattern, DefaultDatePattern )
        self.keep         = options.fetch( :keep, 0 )

        @file_basename    = options.fetch( :filename, default_filename )
        options[:filename]  = @file_basename
      end

      write do |event|
        if close?
          close

          unless ::File.exist?( @filename )
            cleanup if cleanup?

            stream.print( "# -*- #{@date.iso8601} (#{@date.to_f}) [#{date_pattern}] -*-\n" )
          end
        end
      end

      close do
        @filename = filename_from( @date )
      end


      # The pattern to be used for the files
      #
      # @example
      #   date_pattern = "%Y%m%d"       # default
      #   date_pattern = "%Y-week-%V"
      attr_accessor :date_pattern

      # Set the amount of logfiles to keep when rolling over.
      # By default, no files will be cleaned up.
      #
      # @example Keep the last 5 logfiles
      #   keep = 5
      #   keep = '10'
      #
      # @example Do not clean up any files
      #   keep = 0
      attr_accessor :keep


      private

      # Determines whether to close the file handle or not.
      #
      # It is based on the `:date_pattern` (can be passed as option upon initialize). 
      # If the current time hits the pattern, it closes the file stream.
      #
      # @return [Boolean] true or false
      def close?
        _date = Time.now

        if @stream.nil? or _date != @date
          @date = _date
          return true
        end

        false
      end

      # Cleanup old files
      def cleanup
        files = Dir[ @file_basename.sub( /(\.\w+)?$/, ".*\\1" ) ].map do |f|
          [ f, metadata_from(f).last ]
        end.select do |(_, p)|
          @date_pattern == p
        end

        ::File.unlink( *files.map(&:first)[0..-(@keep)] )
      end

      def cleanup?
        keep.to_i > 0
      end

      # Sets the filename with the `:date_pattern` appended to it.
      def filename_from( date )
        @file_basename.sub( /(\.\w+)?$/, ".#{date.strftime(@date_pattern)}\\1" )
      end

      def metadata_from( file )
        if m = ::File.open( file, &:readline ).match( /^# -\*- (.+) \((\d+\.\d+)\) \[(.+)\] -\*-$/ )
          [ Time.at( m[2].to_f ), m[3] ]
        else
          [ ::File.mtime( file ), "" ]
        end
      end

    end

    register( :datefile, Yell::Adapters::Datefile )

  end
end


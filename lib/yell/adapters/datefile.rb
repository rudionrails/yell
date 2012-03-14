# encoding: utf-8

module Yell #:nodoc:
  module Adapters #:nodoc:

    # The +Datefile+ adapter is similar to the +File+ adapter. However, it
    # rotates the file at midnight.
    class Datefile < Yell::Adapters::File

      # The default date pattern, e.g. "19820114" (14 Jan 1982)
      DefaultDatePattern = "%Y%m%d"

      def initialize( options = {}, &block )
        @date_pattern = options[:date_pattern] || DefaultDatePattern

        @file_basename = options[:filename] || default_filename
        options[:filename] = @file_basename

        @date = nil # default; do not override --R

        super( options, &block )
      end

      def write( level, message )
        reset! if reset?

        super( level, message )
      end

      # @override Reset the file handle
      def reset!
        @filename = new_filename

        super
      end


      private

      # Determines whether to reset the file handle or not.
      #
      # It is based on the `:date_pattern` (can be passed as option upon initialize). 
      # If the current time hits the pattern, it resets the file handle.
      #
      # @return [Boolean] true or false
      def reset?
        _date = Time.now.strftime( @date_pattern )
        if closed? or _date != @date
          @date = _date
          return true
        end

        false
      end

      # Sets the filename with the `:date_pattern` appended to it.
      def new_filename
        @file_basename.sub( /(\.\w+)?$/, ".#{@date}\\1" )
      end

    end

  end
end

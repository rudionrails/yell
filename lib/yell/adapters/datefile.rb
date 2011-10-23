module Yell::Adapters
  class Datefile < Yell::Adapters::File

    DefaultDatePattern = "%Y%m%d"

    def initialize ( options = {}, &block )
      @date_pattern = options[:date_pattern] || DefaultDatePattern
      @date = nil # default; do not override --R

      @file_basename = options[:filename] || default_filename
      options[:filename] = @file_basename

      super( options, &block )
    end

    def reset!( now )
      @filename = new_filename
      super( now )
    end


    private

    def reset?
      _date = Time.now.strftime( @date_pattern )
      unless opened? && _date == @date
        @date = _date
        return true
      end

      false
    end

    def new_filename
      @file_basename.sub( /(\.\w+)?$/, ".#{@date}\\1" )
    end

  end
end

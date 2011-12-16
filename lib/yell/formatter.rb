module Yell
  class Formatter

    PatternTable = {
      "m" => "message", 
      "d" => "date",
      "l" => "level.downcase",
      "L" => "level.upcase",
      "p" => "$$", # pid
      "h" => "hostname"
    }
    PatternRegexp = /([^%]*)(%\d*)?([dlLphm])?(.*)/
    DefaultPattern = "%d [%5L] %p %h: %m"


    def initialize ( pattern = nil, date_pattern = nil )
      @pattern = pattern || DefaultPattern
      @date_pattern = date_pattern # may be nil

      define_format_method
    end


    private

    def define_format_method
      buff, args, _pattern = "", [], @pattern.dup

      while true
        match = PatternRegexp.match( _pattern )

        buff << match[1] unless match[1].empty? 
        break if match[2].nil?

        buff << match[2] + 's' # '%s'
        args << PatternTable[ match[3] ]

        _pattern = match[4]
      end

      instance_eval %-
        def format ( level, message )
          sprintf( "#{buff}", #{args.join(',')} )
        end
      -
    end

    def date
      @date_pattern ? Time.now.strftime( @date_pattern ) : Time.now.iso8601
    end

    def hostname
      return @hostname if defined?( @hostname )
      @hostname = Socket.gethostname rescue nil
    end

  end
end

# encoding: utf-8

module Yell #:nodoc:

  NoFormat        = "%m"
  BasicFormat     = "%l, %d : %m"
  DefaultFormat   = "%d [%5L] %p : %m"
  ExtendedFormat  = "%d [%5L] %p %h : %m"


  def format( pattern, date_pattern ) #:nodoc:
    Yell::Formatter.new( pattern, date_pattern )
  end


  # The +Formatter+ provides a handle to configure your log message style.
  class Formatter

    PatternTable = {
      "m" => "message",
      "d" => "date",
      "l" => "level[0]",
      "L" => "level.upcase",
      "p" => "$$",
      "h" => "hostname"
    }
    PatternRegexp = /([^%]*)(%\d*)?([dlLphm])?(.*)/


    def initialize( pattern = nil, date_pattern = nil )
      @pattern      = pattern || Yell::DefaultFormat
      @date_pattern = date_pattern

      define!
    end


    private

    def define!
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
        def format( level, message )
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


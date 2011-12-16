# encoding: utf-8

module Yell #:nodoc:

  # Conveniently set the logging level
  #
  # @todo Class not in use, implement for future
  class Level

    def initialize( name = nil, filename = nil )
      @operations = []

      at( name, filename ) if name && filename # default
    end

    def at( name, filename )
      @operations << [ :at, name, filename ]

      self
    end

    def gt( name, filename )
      @operations << [ :gt, name, filename ]

      self
    end

    def gte( name, filename )
      @operations << [ :gte, name, filename ]

      self
    end

    def lt( name, filename )
      @operations << [ :lt, name, filename ]

      self
    end

    def lte( name, filename )
      @operations << [ :lte, name, filename ]

      self
    end

  end

end

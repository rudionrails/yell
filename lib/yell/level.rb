# encoding: utf-8

module Yell #:nodoc:

  # Conveniently set the logging level
  #
  # @todo Class not in use, implement for future
  class Level

    def initialize( name = nil )
      @levels = Yell::Severities.map { true }

      gte( name ) if name # default
    end

    def at( name )
      calculate!( :==, name )
      self
    end

    def gt( name )
      calculate!( :>, name )
      self
    end

    def gte( name )
      calculate!( :>=, name )
      self
    end

    def lt( name )
      calculate!( :<, name )
      self
    end

    def lte( name )
      calculate!( :<=, name )
      self
    end


    private

    def calculate!( modifier, name )
    end

  end

end

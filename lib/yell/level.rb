# encoding: utf-8

module Yell #:nodoc:

  # Conveniently set the logging level
  #
  # @todo Class not in use, implement for future
  class Level

    # Different stages of the log levels
    Stages = [ 'debug', 'info', 'warn', 'error', 'fatal', 'unknown' ]

    def initialize( stage = nil )
      @stages = Stages.map { true } # all levels allowed by default

      gte( stage ) if stage
    end

    def at( stage )
      calculate! :==, stage
      self
    end

    def gt( stage )
      calculate! :>, stage
      self
    end

    def gte( stage )
      calculate! :>=, stage
      self
    end

    def lt( stage )
      calculate! :<, stage
      self
    end

    def lte( stage )
      calculate! :<=, stage
      self
    end

    def at?( stage )
      index = index_from( stage )

      return false if index.nil?
      !@stages[index] == false
    end


    private

    def calculate!( modifier, stage )
      index = index_from( stage )
      return if index.nil?

      case modifier
        when :>   then ascending!( index+1 )
        when :>=  then ascending!( index )
        when :<   then descending!( index-1 )
        when :<=  then descending!( index )
        else @stages[index] = true
      end
    end

    def index_from( stage )
      case stage
        when Integer then stage
        when String, Symbol then Stages.index( stage.to_s )
        else nil
      end
    end

    def ascending!( index )
      @stages.each_with_index do |s, i|
        next if s == false # skip

        if i < index
          @stages[i] = false
        else
          @stages[i] = true
        end
      end
    end

    def descending!( index )
      @stages.each_with_index do |s, i|
        next if s == false # skip

        if index < i
          @stages[i] = false
        else
          @stages[i] = true
        end
      end
    end

  end

end

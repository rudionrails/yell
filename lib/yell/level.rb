# encoding: utf-8

module Yell #:nodoc:

  # The +Level+ class handles the severities for you in order to determine 
  # if an adapter should log or not.
  #
  # In order to setup your level, you have certain modifiers available:
  #   at :warn    # will be set to :warn level only
  #   gt :warn    # Will set from :error level onwards
  #   gte :warn   # Will set from :warn level onwards
  #   lt :warn    # Will set from :info level an below
  #   lte :warn   # Will set from :warn level and below
  #
  # You are able to combine those modifiers to your convenience.
  #
  # @example Set from :info to :error (including)
  #   Yell::Level.new(:info).lte(:error)
  #
  # @example Set from :info to :error (excluding)
  #   Yell::Level.new(:info).lt(:error)
  #
  # @example Set at :info only
  #   Yell::Level.new.at(:info)
  class Level
    module Helpers
      # Accessor to the log level
      attr_reader :level

      # Set the minimum log level.
      #
      # @example Set the level to :warn
      #   level = :warn
      #
      # @param [String, Symbol, Integer] val The minimum log level
      def level=( severity )
        @level = case severity
          when Yell::Level then severity
          else Yell::Level.new( severity )
        end
      end
    end

    attr_reader :severities

    # Create a new level instance.
    #
    # @example Enable all severities
    #   Yell::Level.new
    #
    # @example Pass the minimum possible severity
    #   Yell::Level.new :warn
    #
    # @example Pass an array to exactly set the level at the given severities
    #   Yell::Level.new [:info, :error]
    #
    # @example Pass a range to set the level within the severities
    #   Yell::Level.new (:info..:error)
    #
    # @param [Integer,String,Symbol,Array,Range,nil] severity The severity for the level.
    def initialize( severity = nil )
      reset!

      case severity
        when Array then at( *severity )
        when Range then gte(severity.first).lte(severity.last)
        when Integer, String, Symbol then gte(severity)
      end
    end

    def reset!
      @severities = Yell::Severities.map { true }
    end

    # Returns whether the level is allowed at the given severity
    #
    # @example
    #   at? :warn
    #   at? 0       # debug
    def at?( severity )
      index = index_from( severity )

      index.nil? ? false : @severities[index]
    end

    # to_i implements backwards compatibility
    def to_i
      @severities.each_with_index { |s,i| return i if s == true }
    end
    alias :to_int :to_i

    def at( *severities ) #:nodoc:
      severities.each { |severity| calculate! :==, severity }
      self
    end

    def gt( severity ) #:nodoc:
      calculate! :>, severity
      self
    end

    def gte( severity ) #:nodoc:
      calculate! :>=, severity
      self
    end

    def lt( severity ) #:nodoc:
      calculate! :<, severity
      self
    end

    def lte( severity ) #:nodoc:
      calculate! :<=, severity
      self
    end


    private

    def calculate!( modifier, severity ) #:nodoc:
      index = index_from( severity )
      return if index.nil?

      case modifier
        when :>   then ascending!( index+1 )
        when :>=  then ascending!( index )
        when :<   then descending!( index-1 )
        when :<=  then descending!( index )
        else set!( index ) # :==
      end

      taint unless tainted?
    end

    def index_from( severity ) #:nodoc:
      case severity
        when Integer        then severity
        when String, Symbol then Yell::Severities.index( severity.to_s.upcase )
        else nil
      end
    end

    def ascending!( index ) #:nodoc:
      @severities.each_with_index do |s, i|
        next if s == false # skip

        @severities[i] = i < index ? false : true
      end
    end

    def descending!( index ) #:nodoc:
      @severities.each_with_index do |s, i|
        next if s == false # skip

        @severities[i] = index < i ? false : true
      end
    end

    def set!( index ) #:nodoc:
      @severities.map! { false } unless tainted?

      @severities[index] = true
    end

  end

end

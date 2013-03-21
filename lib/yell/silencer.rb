# encoding: utf-8
module Yell #:nodoc:

  class Silencer
    module Helpers
      # Accessor to the silencer
      attr_reader :silencer

      # Set the silence pattern
      def silence=( pattern )
        @silencer = case pattern
        when Yell::Silencer then pattern
        when Regexp then Yell::Silencer.new( pattern )
        end
      end

      private

      def silence?
        !@silencer.nil?
      end

      def silence!( messages )
        Array(messages).reject! { |m| silencer.matches?(m) }
      end
    end

    def initialize( pattern )
      @pattern = pattern
    end

    def matches?( message )
      !!@pattern.match( message )
    end

  end
end


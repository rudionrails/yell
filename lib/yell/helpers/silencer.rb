# encoding: utf-8
module Yell #:nodoc:
  module Helpers #:nodoc:
    module Silencer

      # Set the silence pattern
      def silence( *patterns )
        silencer.add(*patterns)
      end

      # @private
      def silencer
        @silencer
      end


      private

      def reset!
        @silencer = Yell::Silencer.new

        super
      end

      def silence!( *messages )
        silencer.silence!(*messages) if silencer.silence?
      end

    end
  end
end


require 'spec_helper'

describe Yell do

  describe "a new Yell instance" do
    let( :logger ) { Yell.new }

    it "should return a Yell::Logger" do
      logger.should be_kind_of( Yell::Logger )
    end

    it "should raise NoSuchAdapter when adapter cant be loaded" do
      lambda { Yell.new :unknownadapter }.should raise_error( Yell::NoSuchAdapter )
    end
  end

end

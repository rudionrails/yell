require 'spec_helper'

describe Yell do
  subject { Yell.new }

  it { should be_kind_of Yell::Logger }

  it "should raise NoSuchAdapter when adapter cant be loaded" do
    lambda { Yell.new :unknownadapter }.should raise_error( Yell::NoSuchAdapter )
  end

  context :level do
    subject { Yell.level }

    it { should be_kind_of Yell::Level }
  end

  context :format do
    subject { Yell.format( "%m" ) }

    it { should be_kind_of Yell::Formatter }
  end

end

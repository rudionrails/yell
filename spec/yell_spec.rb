require 'spec_helper'

describe Yell do
  subject { Yell.new }

  it { should be_kind_of Yell::Logger }

  it "should raise UnregisteredAdapter when adapter cant be loaded" do
    lambda { Yell.new :unknownadapter }.should raise_error( Yell::UnregisteredAdapter )
  end

  context :level do
    subject { Yell.level }

    it { should be_kind_of Yell::Level }
  end

  context :format do
    subject { Yell.format( "%m" ) }

    it { should be_kind_of Yell::Formatter }
  end

  context :load! do
    subject { Yell.load!( File.dirname(__FILE__) + '/fixtures/yell.yml' ) }

    let( :adapters ) { subject.instance_variable_get :@adapters }

    it { should be_kind_of Yell::Logger }

    it "should return a Yell instacne with the configuration for a file" do
      adapters.first.should be_kind_of Yell::Adapters::Stdout
      adapters.last.should be_kind_of Yell::Adapters::Stderr
    end
  end

end

require 'spec_helper'

describe Yell do
  let( :logger ) { Yell.new }

  subject { logger }

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
    subject { Yell.load!( 'yell.yml' ) }

    before do
      mock( Yell::Configuration ).load!( 'yell.yml' ) { {} }
    end

    it { should be_kind_of Yell::Logger }
  end

  context :[] do
    let( :name ) { 'test' }

    it "should delegate to the repository" do
      mock( Yell::Repository )[ name ]

      Yell[ name ]
    end
  end

  context :[]= do
    let( :name ) { 'test' }

    it "should delegate to the repository" do
      mock.proxy( Yell::Repository )[name] = logger

      Yell[ name ] = logger
    end
  end

  context :loggers do
    it "should delegate to the repository" do
      mock.proxy( Yell::Repository ).loggers

      Yell.loggers
    end
  end

end


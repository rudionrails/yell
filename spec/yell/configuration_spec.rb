require 'spec_helper'

describe Yell::Configuration do

  describe ":load!" do
    let( :file ) { fixture_path + '/yell.yml' }
    let( :configuration ) { Yell::Configuration.load!( file ) }

    it { configuration.should be_kind_of Hash }
    it { configuration.should have_key :level }
    it { configuration.should have_key :adapters }

    it "should set the correct :level" do
      configuration[:level].should == "info"
    end

    it "should set the correct :adapters" do
      configuration[:adapters].should be_kind_of Array

      # stdout
      configuration[:adapters][0].should == :stdout

      # stderr
      configuration[:adapters][1].should be_kind_of Hash
      configuration[:adapters][1].should == { :stderr => {:level => 'gte.error'} }
    end
  end

end


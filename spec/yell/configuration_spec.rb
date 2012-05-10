require 'spec_helper'

describe Yell::Configuration do

  describe ":load!" do
    let( :file ) { File.expand_path File.dirname(__FILE__) + '/../fixtures/yell.yml' }
    let( :configuration ) { Yell::Configuration.load!( file ) }

    it "should return the hash from the given file" do
      YAML.load( File.read(file) ).should == configuration
    end
  end

end


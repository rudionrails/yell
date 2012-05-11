require 'spec_helper'

describe Yell::Configuration do

  describe ":load!" do
    let( :file ) { File.dirname(__FILE__) + '/../fixtures/yell.yml' }
    let( :configuration ) { Yell::Configuration.load!( file ) }

    it "should return the hash from the given file" do
      YAML.load_file( file )['development'].should == configuration
    end
  end

end


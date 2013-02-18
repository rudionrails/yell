require 'spec_helper'

describe Yell::Adapters do

  context :new do
    context "given a Yell::Adapters::Base ancestor" do
      let(:stdout) { Yell::Adapters::Stdout.new }

      it "should return the instance" do
        Yell::Adapters.new( stdout ).should == stdout
      end
    end

    context "given STDOUT" do
      it "should initialize Stdout adapter" do
        mock.proxy( Yell::Adapters::Stdout ).new( anything )

        Yell::Adapters.new STDOUT
      end
    end

    context "given STDERR" do
      it "should initialize Stderr adapter" do
        mock.proxy( Yell::Adapters::Stderr ).new( anything )

        Yell::Adapters.new STDERR
      end
    end

    context "given an unregistered adapter" do
      it "should raise AdapterNotFound" do
        lambda { Yell::Adapters.new :unknown }.should raise_error Yell::AdapterNotFound
      end
    end
  end

  context :register do
    let(:name) { :test }
    let(:klass) { mock }

    before { Yell::Adapters.register( name, klass ) }

    it "should allow to being called from :new" do
      mock( klass ).new( anything )

      Yell::Adapters.new(name)
    end
  end

end

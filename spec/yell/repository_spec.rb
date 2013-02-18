require 'spec_helper'

describe Yell::Repository do
  let(:name) { 'test' }
  let(:logger) { Yell.new :stdout }

  subject { Yell::Repository[name] }


  context ".[]" do
    it "should raise when not set" do
      lambda { subject }.should raise_error( Yell::LoggerNotFound )
    end

    it "should return the logger when set" do
      Yell::Repository[ name ] = logger

      subject.should == logger
    end

    context "given a Class" do
      before do
        @logger = Yell.new :stdout, :name => "Numeric"
      end

      it "should raise with the correct :name when logger not found" do
        mock.proxy( Yell::LoggerNotFound ).new( String )

        lambda { Yell::Repository[ String ] }.should raise_error( Yell::LoggerNotFound )
      end

      it "should return the logger" do
        Yell::Repository[ Numeric ].should == @logger
      end

      it "should return the logger when superclass has it defined" do
        Yell::Repository[ Integer ].should == @logger
      end
    end
  end

  context ".[]=" do
    before do
      Yell::Repository[ name ] = logger
    end

    it { should == logger }
  end

  context "[]= with a named logger" do
    before do
      Yell::Repository[ name ] = Yell.new :stdout, :name => name
    end

    it { should_not be_nil }
  end

  context "[]= with a named logger of other name" do
    let(:other) { 'other' }
    let(:logger) { Yell.new :stdout, :name => other }

    before do
      Yell::Repository[ name ] = logger
    end

    it "should add logger to both repositories" do
      Yell::Repository[name].should == logger
      Yell::Repository[other].should == logger
    end
  end

  context "loggers" do
    let(:loggers) { { name => logger } }

    subject { Yell::Repository.loggers }

    before do
      Yell::Repository[ name ] = logger
    end

    it { should == loggers }
  end

end


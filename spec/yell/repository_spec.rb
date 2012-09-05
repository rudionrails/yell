require 'spec_helper'

describe Yell::Repository do
  let( :name ) { 'test' }
  let( :logger ) { Yell.new :stdout }

  subject { Yell::Repository[name] }


  context ".[]" do
    context "when not set" do
      it { should be_nil }
    end

    context "when assigned" do
      before do
        Yell::Repository[ name ] = logger
      end

      it { should == logger }
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
    let( :other ) { 'other' }
    let( :logger ) { Yell.new :stdout, :name => other }

    before do
      Yell::Repository[ name ] = logger
    end

    it "should add logger to both repositories" do
      Yell::Repository[name].should == logger
      Yell::Repository[other].should == logger
    end
  end

  context "loggers" do
    let( :loggers ) { { name => logger } }

    subject { Yell::Repository.loggers }

    before do
      Yell::Repository[ name ] = logger
    end

    it { should == loggers }
  end

  context "clear" do
    subject { Yell::Repository.loggers }

    before do
      Yell::Repository[ name ] = logger
      Yell::Repository.clear
    end

    it { should be_empty }
  end
end


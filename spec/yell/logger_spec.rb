require 'spec_helper'

describe Yell::Logger do

  context "a Logger instance" do
    let( :logger ) { Yell::Logger.new }

    context "log methods" do
      subject { logger }

      it { should respond_to :debug }
      it { should respond_to :debug? }

      it { should respond_to :info }
      it { should respond_to :info? }

      it { should respond_to :warn }
      it { should respond_to :warn? }

      it { should respond_to :error }
      it { should respond_to :error? }

      it { should respond_to :fatal }
      it { should respond_to :fatal? }

      it { should respond_to :unknown }
      it { should respond_to :unknown? }
    end

    context "default adapter" do
      let( :adapters ) { logger.instance_variable_get :@adapters }

      it { adapters.size.should == 1 }
      it { adapters.first.should be_kind_of Yell::Adapters::File }
    end
  end

  context "a Logger instance with a given :filename" do
    it "should call adapter with :file" do
      mock.proxy( Yell::Adapters::File ).new( :filename => 'test.log' )

      Yell::Logger.new 'test.log'
    end
  end

  context "a Logger instance with a given :stdout adapter" do
    before do
      mock.proxy( Yell::Adapters::Stdout ).new( anything )
    end

    it "should call adapter with :stdout" do
      Yell::Logger.new STDOUT
    end

    it "should call adapter with :stdout" do
      Yell::Logger.new :stdout
    end
  end

  context "a Logger instance with a given :stderr adapter" do
    before do
      mock.proxy( Yell::Adapters::Stderr ).new( anything )
    end

    it "should call adapter with :stderr" do
      Yell::Logger.new STDERR
    end

    it "should call adapter with :stderr" do
      Yell::Logger.new :stderr
    end
  end

  context "a Logger instance with a given block" do
    let( :level ) { Yell::Level.new :error }
    let( :adapter ) { Yell::Adapters::Stdout.new }

    let( :logger ) do 
      Yell::Logger.new do |l| 
        l.level = level
        l.adapter adapter
      end
    end

    it "should set the level" do
      logger.level.severities.should == level.severities
    end

    it "should define adapter" do
      adapters = logger.instance_variable_get :@adapters

      adapters.size.should == 1
      adapters.first.should == adapter
    end
  end

end


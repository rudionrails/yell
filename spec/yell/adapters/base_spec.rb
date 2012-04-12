require 'spec_helper'

describe Yell::Adapters::Base do

  context "initialize with :level" do
    before do
      any_instance_of( Yell::Adapters::Base ) do |base|
        mock( base ).level= :info
      end
    end

    it "should set the level" do
      Yell::Adapters::Base.new :level => :info
    end
  end

  context "insitialize with :block" do
    context :level do
      before do
        any_instance_of( Yell::Adapters::Base ) do |base|
          mock( base ).level= :info
        end
      end

      it "should set the level" do
        Yell::Adapters::Base.new :level => :info
      end
    end
  end

  context :options do
    let( :options ) { { :my => :options } }
    let( :adapter ) { Yell::Adapters::Base.new( options ) }

    it { options.should == options }
  end

  context :write do
    subject { Yell::Adapters::Base.new :level => :info }

    it "should delegate :event to :write!" do
      event = Yell::Event.new( "INFO", "Hello World!" )

      mock( subject ).write!( event )

      subject.write( event )
    end

    it "should not write when event does not have the right level" do
      event = Yell::Event.new( "DEBUG", "Hello World!" )

      dont_allow( subject ).write!( event )

      subject.write( event )
    end
  end

end


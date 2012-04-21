require 'spec_helper'

describe Yell::Adapters::Io do

  it { should be_kind_of Yell::Adapters::Base }

  context "initialize" do
    it "should set default :format" do
      adapter = Yell::Adapters::Io.new

      adapter.format.should be_kind_of Yell::Formatter
    end

    context :level do
      let( :level ) { Yell::Level.new(:warn) }

      it "should set the level" do
        adapter = Yell::Adapters::Io.new :level => level
        adapter.level.should == level
      end

      it "should set the level when block was given" do
        adapter = Yell::Adapters::Io.new { |a| a.level = level }
        adapter.level.should == level
      end
    end

    context :format do
      let( :format ) { Yell::Formatter.new }

      it "should set the level" do
        adapter = Yell::Adapters::Io.new :format => format
        adapter.format.should == format
      end

      it "should set the level when block was given" do
        adapter = Yell::Adapters::Io.new { |a| a.format = format }
        adapter.format.should == format
      end
    end
  end

  context :stream do
    it "should raise" do
      lambda { Yell::Adapters::Io.new.send :stream }.should raise_error("Not implemented" )
    end
  end

  context :write do
    let( :event ) { Yell::Event.new("INFO", "Hello World") }
    let( :adapter ) { Yell::Adapters::Io.new }
    let( :stream ) { File.new('/dev/null', 'w') }

    before do
      stub( adapter ).stream { stream }
    end

    it "should format the message" do
      mock.proxy( adapter.format ).format( event )

      adapter.write( event )
    end

    it "should print formatted message to stream" do
      formatted = Yell::Formatter.new.format( event )
      mock( stream ).write( formatted << "\n" )

      adapter.write( event )
    end
  end

end


require 'spec_helper'

# Since Yell::Event.new is not called directly, but through
# the logger methods, we need to divert here in order to get 
# the correct caller.
class EventFactory
  def self.event( level, message )
    self._event( level, message )
  end

  private

  def self._event( level, message )
    Yell::Event.new level, message
  end

end

describe Yell::Event do
  let(:event) { Yell::Event.new 1, 'Hello World!', :test => :option }

  context :caller do
    let( :event ) { EventFactory.event 1, "Hello World" }

    context :file do
      subject { event.file }
      it  { should == __FILE__ }
    end

    context :line do
      subject { event.line }
      it { should == "8" }
    end

    context :method do
      subject { event.method }
      it { should == 'event' }
    end
  end

  context :level do
    subject { event.level }
    it { should == 1 }
  end

  context :message do
    subject { event.message }
    it { should == 'Hello World!' }
  end

  context :options do
    subject { event.options }
    it { should == { :test => :option } }
  end

  context :time do
    subject { event.time }

    let(:time) { Time.now }

    before do
      Timecop.freeze( time )
    end

    it { should == time }
  end

  context :hostname do
    subject { event.hostname }
    it { should == Socket.gethostname }
  end

  context :pid do
    subject { event.pid }
    it { should == Process.pid }
  end

end

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
  let(:event) { Yell::Event.new 1, 'Hello World!' }

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

  context :messages do
    subject { event.messages }
    it { should == ['Hello World!'] }
  end

  context :time do
    subject { event.time.to_s }

    let(:time) { Time.now }

    before do
      Timecop.freeze( time )
    end

    it { should == time.to_s }
  end

  context :hostname do
    subject { event.hostname }
    it { should == Socket.gethostname }
  end

  context :pid do
    subject { event.pid }
    it { should == Process.pid }
  end

  context :progname do
    subject { event.progname }
    it { should == $0 }
  end
end

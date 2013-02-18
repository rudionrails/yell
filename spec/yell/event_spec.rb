require 'spec_helper'

# Since Yell::Event.new is not called directly, but through
# the logger methods, we need to divert here in order to get 
# the correct caller.
class EventFactory
  def self.event(logger, level, message)
    self._event(logger, level, message)
  end

  private

  def self._event(logger, level, message)
    Yell::Event.new(logger, level, message)
  end

end

describe Yell::Event do
  let(:logger) { Yell::Logger.new(:trace => true) }
  let(:event) { Yell::Event.new(logger, 1, 'Hello World!') }

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

  context "pid when forked", :pending => RUBY_PLATFORM == 'java' do # no forking with jruby
    subject { @pid }

    before do
      read, write = IO.pipe

      @pid = Process.fork do
        event = Yell::Event.new(logger, 1, 'Hello World!')
        write.puts event.pid
      end
      Process.wait
      write.close

      @child_pid = read.read.to_i
      read.close
    end

    it { should_not == Process.pid }
    it { should == @child_pid }
  end

  context :progname do
    subject { event.progname }
    it { should == $0 }
  end

  context :caller do
    subject { EventFactory.event(logger, 1, "Hello World") }

    context "with trace" do
      its(:file) { should == __FILE__ }
      its(:line) { should == "8" }
      its(:method) { should == "event" }
    end

    context "without trace" do
      before { logger.trace = false }

      its(:file) { should == "" }
      its(:line) { should == "" }
      its(:method) { should == "" }
    end
  end

end

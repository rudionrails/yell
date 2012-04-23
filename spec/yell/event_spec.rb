require 'spec_helper'

describe Yell::Event do
  let(:event) { Yell::Event.new 1, 'Hello World!' }

  context :level do
    subject { event.level }
    it { should == 1 }
  end

  context :message do
    subject { event.message }
    it { should == 'Hello World!' }
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

  context :caller do
    let(:file) { "event.rb" }
    let(:line) { "123" }
    let(:method) { "test_method" }

    before do
      any_instance_of( Yell::Event ) do |e|
        mock( e ).caller { [nil, nil, "#{file}:#{line}:in `#{method}'"] }
      end
    end

    context :file do
      subject { event.file }
      it  { should == file }
    end

    context :line do
      subject { event.line }
      it { should == line }
    end

    context :method do
      subject { event.method }
      it { should == method }
    end
  end

end

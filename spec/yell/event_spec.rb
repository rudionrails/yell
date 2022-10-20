# frozen_string_literal: true

require 'spec_helper'

# Since Yell::Event.new is not called directly, but through
# the logger methods, we need to divert here in order to get
# the correct caller.
class EventFactory
  def self.event(logger, level, message)
    _event(logger, level, message)
  end

  def self._event(logger, level, message)
    Yell::Event.new(logger, level, message)
  end
end

describe Yell::Event do
  let(:logger) { Yell::Logger.new(trace: true) }
  let(:event) { described_class.new(logger, 1, 'Hello World!') }

  describe '#level' do
    subject { event.level }

    it { is_expected.to eq(1) }
  end

  describe '#messages' do
    subject { event.messages }

    it { is_expected.to eq(['Hello World!']) }
  end

  describe '#time' do
    subject { event.time.to_s }

    let(:time) { Time.now }

    before { Timecop.freeze(time) }

    it { is_expected.to eq(time.to_s) }
  end

  describe '#hostname' do
    subject { event.hostname }

    it { is_expected.to eq(Socket.gethostname) }
  end

  describe '#pid' do
    subject { event.pid }

    it { is_expected.to eq(Process.pid) }
  end

  describe '#id when forked', pending: RUBY_PLATFORM == 'java' ? 'No forking with jruby' : false do
    subject { @pid }

    before do
      read, write = IO.pipe

      @pid = Process.fork do
        event = described_class.new(logger, 1, 'Hello World!')
        write.puts event.pid
      end
      Process.wait
      write.close

      @child_pid = read.read.to_i
      read.close
    end

    it { is_expected.not_to eq(Process.pid) }
    it { is_expected.to eq(@child_pid) }
  end

  describe '#progname' do
    subject { event.progname }

    it { is_expected.to eq($PROGRAM_NAME) }
  end

  context ':caller' do
    subject { EventFactory.event(logger, 1, 'Hello World') }

    context 'with trace' do
      it 'has the correct :file' do
        expect(subject.file).to eq(__FILE__)
      end

      it 'has the correct :line' do
        expect(subject.line).to eq('10')
      end

      it 'has the correct :method' do
        expect(subject.method).to eq('event')
      end
    end

    context 'without trace' do
      before { logger.trace = false }

      it 'has the correct :file' do
        expect(subject.file).to eq('')
      end

      it 'has the correct :line' do
        expect(subject.line).to eq('')
      end

      it 'has the correct :method' do
        expect(subject.method).to eq('')
      end
    end
  end
end

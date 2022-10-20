# frozen_string_literal: true

require 'spec_helper'

# if you move the LoggerFactory lines, it will change the trace, so be careful
class LoggerFactory
  attr_accessor :logger

  def info
    logger.info :foo
  end

  def add
    logger.add 1, :bar
  end
end

describe Yell::Logger do
  let(:filename) { "#{fixture_path}/logger.log" }

  describe 'a Logger instance' do
    subject { logger }

    let(:logger) { described_class.new }

    context 'log methods' do
      it { is_expected.to respond_to(:debug) }
      it { is_expected.to respond_to(:debug?) }

      it { is_expected.to respond_to(:info) }
      it { is_expected.to respond_to(:info?) }

      it { is_expected.to respond_to(:warn) }
      it { is_expected.to respond_to(:warn?) }

      it { is_expected.to respond_to(:error) }
      it { is_expected.to respond_to(:error?) }

      it { is_expected.to respond_to(:fatal) }
      it { is_expected.to respond_to(:fatal?) }

      it { is_expected.to respond_to(:unknown) }
      it { is_expected.to respond_to(:unknown?) }
    end

    context 'default #name' do
      it 'has the correct name' do
        expect(logger.name).to eq("<Yell::Logger##{logger.object_id}>")
      end

      it 'is not added to the repository' do
        expect { Yell::Repository[logger.name] }.to raise_error(Yell::LoggerNotFound)
      end
    end

    context 'default #adapter' do
      subject { logger.adapters.instance_variable_get(:@collection) }

      it 'has is a file adapter' do
        expect(subject.size).to eq(1)
        expect(subject.first).to be_a(Yell::Adapters::File)
      end
    end

    context 'default #level' do
      subject { logger.level }

      it { is_expected.to be_instance_of(Yell::Level) }

      it 'has the right values' do
        expect(subject.severities).to eq([true, true, true, true, true, true])
      end
    end

    context 'default #trace' do
      subject { logger.trace }

      it { is_expected.to be_instance_of(Yell::Level) }

      it 'is configured from error level onwards' do
        expect(subject.severities).to eq([false, false, false, true, true, true])
      end
    end
  end

  describe 'initialize with #name' do
    let(:name) { 'test' }
    let!(:logger) { Yell.new(name:) }

    it 'sets the name correctly' do
      expect(logger.name).to eq(name)
    end

    it 'is added to the repository' do
      expect(Yell::Repository[name]).to eq(logger)
    end
  end

  context 'initialize with #level' do
    subject { logger.level }

    let(:level) { :warn }
    let(:logger) { Yell.new(level:) }

    it { is_expected.to be_instance_of(Yell::Level) }

    it 'has the correct values' do
      expect(subject.severities).to eq([false, false, true, true, true, true])
    end
  end

  context 'initialize with #trace' do
    subject { logger.trace }

    let(:trace) { :info }
    let(:logger) { Yell.new(trace:) }

    it { is_expected.to be_instance_of(Yell::Level) }

    it 'has the correct values' do
      expect(subject.severities).to eq([false, true, true, true, true, true])
    end
  end

  context 'initialize with #silence' do
    subject { logger.silencer }

    let(:silence) { 'test' }
    let(:logger) { Yell.new(silence:) }

    it { is_expected.to be_instance_of(Yell::Silencer) }

    it 'has the correct values' do
      expect(subject.patterns).to eq([silence])
    end
  end

  context 'initialize with a #filename' do
    # let(:adapters) { logger.adapters.instance_variable_get(:@collection) }

    it 'calls adapter with :file' do
      expect(Yell::Adapters::File).to(
        receive(:new).with(hash_including(filename:)).and_call_original
      )

      described_class.new(filename)
      # adapter = logger.adapters.instance_variable_get(:@collection).first
      #
      # expect(adapter).to be_kind_of(Yell::Adapters::File)
    end

    it 'calls adapter with :file of type Pathname' do
      pathname = Pathname.new(filename)

      expect(Yell::Adapters::File).to(
        receive(:new).with(hash_including(filename: pathname)).and_call_original
      )

      described_class.new(pathname)
    end
  end

  context 'initialize with a :stdout adapter' do
    before do
      expect(Yell::Adapters::Stdout).to receive(:new)
    end

    it 'calls adapter with STDOUT' do
      described_class.new($stdout)
    end

    it 'calls adapter with :stdout' do
      described_class.new(:stdout)
    end
  end

  context 'initialize with a :stderr adapter' do
    before do
      expect(Yell::Adapters::Stderr).to receive(:new)
    end

    it 'calls adapter with STDERR' do
      described_class.new($stderr)
    end

    it 'calls adapter with :stderr' do
      described_class.new(:stderr)
    end
  end

  context 'initialize with a block' do
    let(:level) { Yell::Level.new :error }
    let(:adapters) { logger.adapters.instance_variable_get(:@collection) }

    context 'with arity' do
      let(:logger) do
        described_class.new(level:) { |l| l.adapter(:stdout) }
      end

      it 'passes the level correctly' do
        expect(logger.level).to eq(level)
      end

      it 'passes the adapter correctly' do
        expect(adapters.first).to be_instance_of(Yell::Adapters::Stdout)
      end
    end

    context 'without arity' do
      let(:logger) do
        described_class.new(level:) { adapter(:stdout) }
      end

      it 'passes the level correctly' do
        expect(logger.level).to eq(level)
      end

      it 'passes the adapter correctly' do
        expect(adapters.first).to be_instance_of(Yell::Adapters::Stdout)
      end
    end
  end

  context 'initialize with #adapters option' do
    it 'sets adapters in logger correctly' do
      expect(Yell::Adapters::Stdout).to(
        receive(:new)
          .and_call_original
      )
      expect(Yell::Adapters::Stderr).to(
        receive(:new)
          .with(hash_including(level: :error))
          .and_call_original
      )

      described_class.new(
        adapters: [
          :stdout,
          { stderr: { level: :error } }
        ]
      )
    end
  end

  context "caller's :file, :line and :method" do
    let(:stdout) { Yell::Adapters::Stdout.new(format: '%F, %n: %M') }
    let(:logger) { described_class.new(trace: true) { |l| l.adapter(stdout) } }

    it 'writes correctly' do
      factory = LoggerFactory.new
      factory.logger = logger

      expect(stdout.send(:stream)).to(
        receive(:syswrite).with("#{__FILE__}, 10: info\n")
      )
      expect(stdout.send(:stream)).to(
        receive(:syswrite).with("#{__FILE__}, 14: add\n")
      )

      factory.info
      factory.add
    end
  end

  context 'logging in general' do
    let(:logger) { described_class.new(filename, format: '%m') }
    let(:line) { File.open(filename, &:readline) }

    it 'outputs a single message' do
      logger.info 'Hello World'

      expect(line).to eq("Hello World\n")
    end

    it 'outputs multiple messages' do
      # logger.info ["Hello", "W", "o", "r", "l", "d"]
      logger.info %w[Hello W o r l d]
      expect(line).to eq("Hello W o r l d\n")
    end

    it 'outputs a hash and message' do
      logger.info ['Hello World', { test: :message }]

      expect(line).to eq("Hello World test: message\n")
    end

    it 'outputs a hash and message' do
      logger.info [{ test: :message }, 'Hello World']

      expect(line).to eq("test: message Hello World\n")
    end

    it 'outputs a hash and block' do
      logger.info(test: :message) { 'Hello World' }

      expect(line).to eq("test: message Hello World\n")
    end
  end

  context 'logging with a silencer' do
    let(:silence) { 'this' }
    let(:stdout) { Yell::Adapters::Stdout.new }
    let(:logger) { described_class.new(stdout, silence:) }

    it 'does not pass a matching message to any adapter' do
      expect(stdout).not_to receive(:write)

      logger.info 'this should not be logged'
    end

    it 'passes a non-matching message to any adapter' do
      expect(stdout).to receive(:write).with(kind_of(Yell::Event))

      logger.info 'that should be logged'
    end
  end
end

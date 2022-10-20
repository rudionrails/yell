require 'spec_helper'

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
  let(:filename) { fixture_path + '/logger.log' }

  describe "a Logger instance" do
    let(:logger) { Yell::Logger.new }
    subject { logger }

    context "log methods" do
      it { should respond_to(:debug) }
      it { should respond_to(:debug?) }

      it { should respond_to(:info) }
      it { should respond_to(:info?) }

      it { should respond_to(:warn) }
      it { should respond_to(:warn?) }

      it { should respond_to(:error) }
      it { should respond_to(:error?) }

      it { should respond_to(:fatal) }
      it { should respond_to(:fatal?) }

      it { should respond_to(:unknown) }
      it { should respond_to(:unknown?) }
    end

    context "default #name" do
      it "has the correct name" do
        expect(logger.name).to eq("<Yell::Logger##{logger.object_id}>")
      end

      it "should not be added to the repository" do
        expect { Yell::Repository[logger.name] }.to raise_error(Yell::LoggerNotFound)
      end
    end

    context "default #adapter" do
      subject { logger.adapters.instance_variable_get(:@collection) }

      it "has is a file adapter" do
        expect(subject.size).to eq(1)
        expect(subject.first).to be_kind_of(Yell::Adapters::File)
      end
    end

    context "default #level" do
      subject { logger.level }

      it { should be_instance_of(Yell::Level) }

      it "has the right values" do
        expect(subject.severities).to eq([true, true, true, true, true, true])
      end
    end

    context "default #trace" do
      subject { logger.trace }

      it { should be_instance_of(Yell::Level) }

      it "is configured from error level onwards" do
        expect(subject.severities).to eq([false, false, false, true, true, true])
      end
    end
  end

  describe "initialize with #name" do
    let(:name) { 'test' }
    let!(:logger) { Yell.new(name: name) }

    it "should set the name correctly" do
      expect(logger.name).to eq(name)
    end

    it "should be added to the repository" do
      expect(Yell::Repository[name]).to eq(logger)
    end
  end

  context "initialize with #level" do
    let(:level) { :warn }
    let(:logger) { Yell.new(level: level) }
    subject { logger.level }

    it { should be_instance_of(Yell::Level) }

    it "has the correct values" do
      expect(subject.severities).to eq([false, false, true, true, true, true])
    end
  end

  context "initialize with #trace" do
    let(:trace) { :info }
    let(:logger) { Yell.new(trace: trace) }
    subject { logger.trace }

    it { should be_instance_of(Yell::Level) }

    it "has the correct values" do
      expect(subject.severities).to eq([false, true, true, true, true, true])
    end
  end

  context "initialize with #silence" do
    let(:silence) { "test" }
    let(:logger) { Yell.new(silence: silence) }
    subject { logger.silencer }

    it { should be_instance_of(Yell::Silencer) }
    
    it "has the correct values" do
      expect(subject.patterns).to eq([silence])
    end
  end

  context "initialize with a #filename" do
    # let(:adapters) { logger.adapters.instance_variable_get(:@collection) }

    it "should call adapter with :file" do
      expect(Yell::Adapters::File).to(
        receive(:new).with(hash_including(filename: filename)).and_call_original
      )

      Yell::Logger.new(filename)
      # adapter = logger.adapters.instance_variable_get(:@collection).first
      #
      # expect(adapter).to be_kind_of(Yell::Adapters::File)
    end

    it "should call adapter with :file of type Pathname" do
      pathname = Pathname.new(filename)

      expect(Yell::Adapters::File).to(
        receive(:new).with(hash_including(filename: pathname)).and_call_original
      )

      Yell::Logger.new(pathname)
    end
  end

  context "initialize with a :stdout adapter" do
    before do
      expect(Yell::Adapters::Stdout).to receive(:new)
    end

    it "should call adapter with STDOUT" do
      Yell::Logger.new(STDOUT)
    end

    it "should call adapter with :stdout" do
      Yell::Logger.new(:stdout)
    end
  end

  context "initialize with a :stderr adapter" do
    before do
      expect(Yell::Adapters::Stderr).to receive(:new)
    end

    it "should call adapter with STDERR" do
      Yell::Logger.new(STDERR)
    end

    it "should call adapter with :stderr" do
      Yell::Logger.new(:stderr)
    end
  end

  context "initialize with a block" do
    let(:level) { Yell::Level.new :error }
    let(:adapters) { logger.adapters.instance_variable_get(:@collection) }

    context "with arity" do
      let(:logger) do
        Yell::Logger.new(level: level) { |l| l.adapter(:stdout) }
      end

      it "should pass the level correctly" do
        expect(logger.level).to eq(level)
      end

      it "should pass the adapter correctly" do
        expect(adapters.first).to be_instance_of(Yell::Adapters::Stdout)
      end
    end

    context "without arity" do
      let(:logger) do
        Yell::Logger.new(level: level) { adapter(:stdout) }
      end

      it "should pass the level correctly" do
        expect(logger.level).to eq(level)
      end

      it "should pass the adapter correctly" do
        expect(adapters.first).to be_instance_of(Yell::Adapters::Stdout)
      end
    end
  end

  context "initialize with #adapters option" do
    it "should set adapters in logger correctly" do
      expect(Yell::Adapters::Stdout).to(
        receive(:new).
          and_call_original
      )
      expect(Yell::Adapters::Stderr).to(
        receive(:new).
          with(hash_including(level: :error)).
          and_call_original
      )

      Yell::Logger.new(
        adapters: [
          :stdout,
          {stderr: {level: :error}}
        ]
      )
    end
  end

  context "caller's :file, :line and :method" do
    let(:stdout) { Yell::Adapters::Stdout.new(format: "%F, %n: %M") }
    let(:logger) { Yell::Logger.new(trace: true) { |l| l.adapter(stdout) } }

    it "should write correctly" do
      factory = LoggerFactory.new
      factory.logger = logger

      expect(stdout.send(:stream)).to(
        receive(:syswrite).with("#{__FILE__}, 7: info\n")
      )
      expect(stdout.send(:stream)).to(
        receive(:syswrite).with("#{__FILE__}, 11: add\n")
      )

      factory.info
      factory.add
    end
  end

  context "logging in general" do
    let(:logger) { Yell::Logger.new(filename, format: "%m") }
    let(:line) { File.open(filename, &:readline) }

    it "should output a single message" do
      logger.info "Hello World"

      expect(line).to eq("Hello World\n")
    end

    it "should output multiple messages" do
      # logger.info ["Hello", "W", "o", "r", "l", "d"]
      logger.info %w[Hello W o r l d]
      expect(line).to eq("Hello W o r l d\n")
    end

    it "should output a hash and message" do
      logger.info ["Hello World", {test: :message}]

      expect(line).to eq("Hello World test: message\n")
    end

    it "should output a hash and message" do
      logger.info [{test: :message}, "Hello World"]

      expect(line).to eq("test: message Hello World\n")
    end

    it "should output a hash and block" do
      logger.info(:test => :message) { "Hello World" }

      expect(line).to eq("test: message Hello World\n")
    end
  end

  context "logging with a silencer" do
    let(:silence) { "this" }
    let(:stdout) { Yell::Adapters::Stdout.new }
    let(:logger) { Yell::Logger.new(stdout, silence: silence) }

    it "should not pass a matching message to any adapter" do
      expect(stdout).to_not receive(:write)

      logger.info "this should not be logged"
    end

    it "should pass a non-matching message to any adapter" do
      expect(stdout).to receive(:write).with(kind_of(Yell::Event))

      logger.info "that should be logged"
    end
  end

end


require 'spec_helper'

class LoggerFactory
  attr_accessor :logger

  def foo
    logger.info :foo
  end

  def bar
    logger.info :bar
  end
end

describe Yell::Logger do
  let(:filename) { fixture_path + '/logger.log' }

  context "a Logger instance" do
    let(:logger) { Yell::Logger.new }

    its(:name) { should be_nil }

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
      let(:adapters) { logger.instance_variable_get(:@adapters) }

      it { adapters.size.should == 1 }
      it { adapters.first.should be_kind_of(Yell::Adapters::File) }
    end

    context "default :level" do
      subject { logger.level }

      it { should be_instance_of(Yell::Level) }
      its(:severities) { should == [true, true, true, true, true, true] }
    end

    context "default :trace" do
      subject { logger.trace }

      it { should be_instance_of(Yell::Level) }
      its(:severities) { should == [false, false, false, true, true, true] } # from error onwards
    end
  end

  context "initialize with a :name" do
    let(:name) { 'test' }
    let!(:logger) { Yell.new(:name => name) }

    it "should set the logger's name" do
      logger.name.should == name
    end

    it "should be added to the repository" do
      Yell::Repository[name].should == logger
    end
  end

  context "initialize with :trace" do
  end

  context "initialize with a :filename" do
    it "should call adapter with :file" do
      mock.proxy( Yell::Adapters::File ).new( :filename => 'test.log' )

      Yell::Logger.new 'test.log'
    end
  end

  context "initialize with a :filename of Pathname type" do
    it "should call adapter with :file" do
      mock.proxy( Yell::Adapters::File ).new( :filename => Pathname.new('test.log') )

      Yell::Logger.new Pathname.new('test.log')
    end
  end

  context "initialize with a :stdout adapter" do
    before do
      mock.proxy( Yell::Adapters::Stdout ).new( anything )
    end

    it "should call adapter with STDOUT" do
      Yell::Logger.new STDOUT
    end

    it "should call adapter with :stdout" do
      Yell::Logger.new :stdout
    end
  end

  context "initialize with a :stderr adapter" do
    before do
      mock.proxy( Yell::Adapters::Stderr ).new( anything )
    end

    it "should call adapter with STDERR" do
      Yell::Logger.new STDERR
    end

    it "should call adapter with :stderr" do
      Yell::Logger.new :stderr
    end
  end

  context "initialize with a block" do
    let(:level) { Yell::Level.new :error }
    let(:stdout) { Yell::Adapters::Stdout.new }
    let(:adapters) { loggr.instance_variable_get(:@adapters) }

    context "with arity" do
      subject do
        Yell::Logger.new(:level => level) { |l| l.adapter(:stdout) }
      end

      its(:level) { should == level }
      its('adapters.size') { should == 1 }
      its('adapters.first') { should be_instance_of(Yell::Adapters::Stdout) }
    end

    context "without arity" do
      subject do
        Yell::Logger.new(:level => level) { adapter(:stdout) }
      end

      its(:level) { should == level }
      its('adapters.size') { should == 1 }
      its('adapters.first') { should be_instance_of(Yell::Adapters::Stdout) }
    end
  end

  context "initialize with :adapters option" do
    let(:logger) do
      Yell::Logger.new :adapters => [ :stdout, { :stderr => {:level => :error} } ]
    end

    let(:adapters) { logger.instance_variable_get :@adapters }
    let(:stdout) { adapters.first }
    let(:stderr) { adapters.last }

    it "should define those adapters" do
      adapters.size.should == 2

      stdout.should be_kind_of Yell::Adapters::Stdout
      stderr.should be_kind_of Yell::Adapters::Stderr
    end

    it "should pass :level to :stderr adapter" do
      stderr.level.at?(:warn).should be_false
      stderr.level.at?(:error).should be_true
      stderr.level.at?(:fatal).should be_true
    end
  end

  context "caller's :file, :line and :method" do
    let(:stdout) { Yell::Adapters::Stdout.new(:format => "%F, %n: %M") }
    let(:logger) { Yell::Logger.new(:trace => true) { |l| l.adapter(stdout) } }

    it "should write correctly" do
      factory = LoggerFactory.new
      factory.logger = logger

      mock( stdout.send(:stream) ).syswrite( "#{__FILE__}, 7: foo\n" )
      mock( stdout.send(:stream) ).syswrite( "#{__FILE__}, 11: bar\n" )

      factory.foo
      factory.bar
    end
  end

  context "logging in general" do
    let(:logger) { Yell::Logger.new(filename, :format => "%m") }
    let(:line) { File.open(filename, &:readline) }

    it "should output a single message" do
      logger.info "Hello World"
      line.should ==  "Hello World\n"
    end

    it "should output multiple messages" do
      logger.info "Hello", "W", "o", "r", "l", "d"
      line.should == "Hello W o r l d\n"
    end

    it "should output a hash and message" do
      logger.info "Hello World", :test => :message
      line.should == "Hello World test: message\n"
    end

    it "should output a hash and message" do
      logger.info( {:test => :message}, "Hello World" )
      line.should == "test: message Hello World\n"
    end

    it "should output a hash and block" do
      logger.info(:test => :message) { "Hello World" }
      line.should == "test: message Hello World\n"
    end
  end

end


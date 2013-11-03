require 'spec_helper'

describe Yell::Adapters do

  context ".new" do
    it "should accept an adapter instance" do
      stdout = Yell::Adapters::Stdout.new
      adapter = Yell::Adapters.new(stdout)

      expect(adapter).to eq(stdout)
    end

    it "should accept STDOUT" do
      mock.proxy(Yell::Adapters::Stdout).new(anything)

      Yell::Adapters.new(STDOUT)
    end

    it "should accept STDERR" do
      mock.proxy(Yell::Adapters::Stderr).new(anything)

      Yell::Adapters.new(STDERR)
    end

    it "should raise an unregistered adapter" do
      expect {
        Yell::Adapters.new :unknown
      }.to raise_error(Yell::AdapterNotFound)
    end
  end

  context ".register" do
    let(:name) { :test }
    let(:klass) { mock }

    before { Yell::Adapters.register(name, klass) }

    it "should allow to being called from :new" do
      mock(klass).new(anything)

      Yell::Adapters.new(name)
    end
  end

  context "keys for registering and search registered adapters" do
    let(:adapter_class) do 
      klass = mock
      mock(klass).new(anything) { :adapter_instance }
      klass
    end

    before { Yell::Adapters.register(adapter_name, adapter_class) }

    context "registered with string" do
      let(:adapter_name) { "mocked_adapter" }

      it "can be found using string as key" do
        Yell::Adapters.new(adapter_name.to_s).should == :adapter_instance
      end

      it "can be found using symbol as key" do
        Yell::Adapters.new(adapter_name.to_sym).should == :adapter_instance
      end
    end

    context "registered with symbol" do
      let(:adapter_name) { :mocked_adapter }

      it "can be found using string as key" do
        Yell::Adapters.new(adapter_name.to_s).should == :adapter_instance
      end

      it "can be found using symbol as key" do
        Yell::Adapters.new(adapter_name.to_sym).should == :adapter_instance
      end
    end
  end

end

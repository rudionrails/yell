# frozen_string_literal: true

require 'spec_helper'

describe Yell::Adapters do
  describe '.new' do
    it 'accepts an adapter instance' do
      stdout = Yell::Adapters::Stdout.new
      adapter = described_class.new(stdout)

      expect(adapter).to eq(stdout)
    end

    it 'accepts STDOUT' do
      expect(Yell::Adapters::Stdout).to receive(:new).with(anything)

      described_class.new($stdout)
    end

    it 'accepts STDERR' do
      expect(Yell::Adapters::Stderr).to receive(:new).with(anything)

      described_class.new($stderr)
    end

    it 'raises an unregistered adapter' do
      expect do
        described_class.new(:unknown)
      end.to raise_error(Yell::AdapterNotFound)
    end
  end

  describe '.register' do
    let(:type) { :test }
    let(:klass) { double }

    it 'allows to being called from :new' do
      described_class.register(type, klass)
      expect(klass).to receive(:new).with(anything)

      described_class.new(type)
    end
  end
end

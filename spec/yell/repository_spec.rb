# frozen_string_literal: true

require 'spec_helper'

describe Yell::Repository do
  subject { described_class[name] }

  let(:name) { 'test' }
  let(:logger) { Yell.new(:stdout) }

  describe '.[]' do
    it 'raises when not set' do
      expect { subject }.to raise_error(Yell::LoggerNotFound)
    end

    context 'when logger with :name exists' do
      let!(:logger) { Yell.new(:stdout, name: name) }

      it 'eq(logger)s' do
        expect(subject).to eq(logger)
      end
    end

    context 'given a Class' do
      let!(:logger) { Yell.new(:stdout, name: 'Numeric') }

      it 'raises with the correct :name when logger not found' do
        expect do
          described_class['does not exist']
        end.to raise_error(Yell::LoggerNotFound)
      end

      it 'returns the logger' do
        expect(described_class[Numeric]).to eq(logger)
      end

      it 'returns the logger when superclass has it defined' do
        expect(described_class[Integer]).to eq(logger)
      end
    end
  end

  describe '.[]=' do
    before { described_class[name] = logger }

    it 'eq(logger)s' do
      expect(subject).to eq(logger)
    end
  end

  describe '.[]= with a named logger' do
    let!(:logger) { Yell.new(:stdout, name: name) }

    before { described_class[name] = logger }

    it 'eq(logger)s' do
      expect(subject).to eq(logger)
    end
  end

  describe '.[]= with a named logger of a different name' do
    let(:other) { 'other' }
    let(:logger) { Yell.new(:stdout, name: other) }

    before { described_class[name] = logger }

    it 'adds logger to both repositories' do
      expect(described_class[name]).to eq(logger)
      expect(described_class[other]).to eq(logger)
    end
  end

  context 'loggers' do
    subject { described_class.loggers }

    let(:loggers) { { name => logger } }

    before { described_class[name] = logger }

    it 'eq(loggers)s' do
      expect(subject).to eq(loggers)
    end
  end
end

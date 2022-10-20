# frozen_string_literal: true

require 'spec_helper'

describe Yell::Adapters::Io do
  it { is_expected.to be_a Yell::Adapters::Base }

  context 'initialize' do
    it 'sets default :format' do
      adapter = described_class.new

      expect(adapter.format).to be_a(Yell::Formatter)
    end

    context ':level' do
      let(:level) { Yell::Level.new(:warn) }

      it 'sets the level' do
        adapter = described_class.new(level:)

        expect(adapter.level).to eq(level)
      end

      it 'sets the level when block was given' do
        adapter = described_class.new { |a| a.level = level }

        expect(adapter.level).to eq(level)
      end
    end

    context ':format' do
      let(:format) { Yell::Formatter.new }

      it 'sets the level' do
        adapter = described_class.new(format:)

        expect(adapter.format).to eq(format)
      end

      it 'sets the level when block was given' do
        adapter = described_class.new { |a| a.format = format }

        expect(adapter.format).to eq(format)
      end
    end
  end

  describe '#write' do
    let(:logger) { Yell::Logger.new }
    let(:event) { Yell::Event.new(logger, 1, 'Hello World') }
    let(:adapter) { described_class.new }
    let(:stream) { File.new('/dev/null', 'w') }

    before do
      allow(adapter).to receive(:stream) { stream }
    end

    it 'formats the message' do
      expect(adapter.format).to(
        receive(:call).with(event).and_call_original
      )

      adapter.write(event)
    end

    it 'prints formatted message to stream' do
      formatted = Yell::Formatter.new.call(event)
      expect(stream).to receive(:syswrite).with(formatted)

      adapter.write(event)
    end
  end
end

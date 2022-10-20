# frozen_string_literal: true

require 'spec_helper'

describe Yell::Adapters::Base do
  context 'initialize' do
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
  end

  describe '#write' do
    let(:logger) { Yell::Logger.new }
    let(:adapter) { described_class.new(level: 1) }

    it 'delegates :event to :write!' do
      event = Yell::Event.new(logger, 1, 'Hello World!')
      expect(adapter).to receive(:write!).with(event)

      adapter.write(event)
    end

    it 'does not write when event does not have the right level' do
      event = Yell::Event.new(logger, 0, 'Hello World!')
      expect(adapter).not_to receive(:write!)

      adapter.write(event)
    end
  end
end

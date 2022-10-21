# frozen_string_literal: true

require 'spec_helper'

describe Yell::Silencer do
  context 'initialize with #patterns' do
    subject { described_class.new(/this/) }

    it 'has the correct values' do
      expect(subject.patterns).to eq([/this/])
    end
  end

  describe '#add' do
    let(:silencer) { described_class.new }

    it 'adds patterns' do
      silencer.add(/this/, /that/)

      expect(silencer.patterns).to eq([/this/, /that/])
    end

    it 'ignores duplicate patterns' do
      silencer.add(/this/, /that/, /this/)

      expect(silencer.patterns).to eq([/this/, /that/])
    end
  end

  describe '#call' do
    let(:silencer) { described_class.new(/this/) }

    it 'rejects messages that match any pattern' do
      expect(silencer.call('this')).to eq([])
      expect(silencer.call('that')).to eq(['that'])
      expect(silencer.call('this', 'that')).to eq(['that'])
    end
  end
end

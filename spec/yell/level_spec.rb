# frozen_string_literal: true

require 'spec_helper'

describe Yell::Level do
  context 'default' do
    let(:level) { described_class.new }

    it 'shoulds return correctly' do
      expect(level).to be_at(:debug)
      expect(level).to be_at(:info)
      expect(level).to be_at(:warn)
      expect(level).to be_at(:error)
      expect(level).to be_at(:fatal)
    end
  end

  context 'given a Symbol' do
    let(:level) { described_class.new(severity) }

    context ':debug' do
      let(:severity) { :debug }

      it 'shoulds return correctly' do
        expect(level).to be_at(:debug)
        expect(level).to be_at(:info)
        expect(level).to be_at(:warn)
        expect(level).to be_at(:error)
        expect(level).to be_at(:fatal)
      end
    end

    context ':info' do
      let(:severity) { :info }

      it 'shoulds return correctly' do
        expect(level).not_to be_at(:debug)
        expect(level).to be_at(:info)
        expect(level).to be_at(:warn)
        expect(level).to be_at(:error)
        expect(level).to be_at(:fatal)
      end
    end

    context ':warn' do
      let(:severity) { :warn }

      it 'shoulds return correctly' do
        expect(level).not_to be_at(:debug)
        expect(level).not_to be_at(:info)
        expect(level).to be_at(:warn)
        expect(level).to be_at(:error)
        expect(level).to be_at(:fatal)
      end
    end

    context ':error' do
      let(:severity) { :error }

      it 'shoulds return correctly' do
        expect(level).not_to be_at(:debug)
        expect(level).not_to be_at(:info)
        expect(level).not_to be_at(:warn)
        expect(level).to be_at(:error)
        expect(level).to be_at(:fatal)
      end
    end

    context ':fatal' do
      let(:severity) { :fatal }

      it 'shoulds return correctly' do
        expect(level).not_to be_at(:debug)
        expect(level).not_to be_at(:info)
        expect(level).not_to be_at(:warn)
        expect(level).not_to be_at(:error)
        expect(level).to be_at(:fatal)
      end
    end
  end

  context 'given a String' do
    let(:level) { described_class.new(severity) }

    context 'basic string' do
      let(:severity) { 'error' }

      it 'shoulds return correctly' do
        expect(level).not_to be_at(:debug)
        expect(level).not_to be_at(:info)
        expect(level).not_to be_at(:warn)
        expect(level).to be_at(:error)
        expect(level).to be_at(:fatal)
      end
    end

    context 'complex string with outer boundaries' do
      let(:severity) { 'gte.info lte.error' }

      it 'shoulds return correctly' do
        expect(level).not_to be_at(:debug)
        expect(level).to be_at(:info)
        expect(level).to be_at(:warn)
        expect(level).to be_at(:error)
        expect(level).not_to be_at(:fatal)
      end
    end

    context 'complex string with inner boundaries' do
      let(:severity) { 'gt.info lt.error' }

      it 'is valid' do
        expect(level).not_to be_at(:debug)
        expect(level).not_to be_at(:info)
        expect(level).to be_at(:warn)
        expect(level).not_to be_at(:error)
        expect(level).not_to be_at(:fatal)
      end
    end

    context 'complex string with precise boundaries' do
      let(:severity) { 'at.info at.error' }

      it 'is valid' do
        expect(level).not_to be_at(:debug)
        expect(level).to be_at(:info)
        expect(level).not_to be_at(:warn)
        expect(level).to be_at(:error)
        expect(level).not_to be_at(:fatal)
      end
    end

    context 'complex string with combined boundaries' do
      let(:severity) { 'gte.error at.debug' }

      it 'is valid' do
        expect(level).to be_at(:debug)
        expect(level).not_to be_at(:info)
        expect(level).not_to be_at(:warn)
        expect(level).to be_at(:error)
        expect(level).to be_at(:fatal)
      end
    end
  end

  context 'given an Array' do
    let(:level) { described_class.new(%i[debug warn fatal]) }

    it 'returns correctly' do
      expect(level).to be_at(:debug)
      expect(level).not_to be_at(:info)
      expect(level).to be_at(:warn)
      expect(level).not_to be_at(:error)
      expect(level).to be_at(:fatal)
    end
  end

  context 'given a Range' do
    let(:level) { described_class.new((1..3)) }

    it 'returns correctly' do
      expect(level).not_to be_at(:debug)
      expect(level).to be_at(:info)
      expect(level).to be_at(:warn)
      expect(level).to be_at(:error)
      expect(level).not_to be_at(:fatal)
    end
  end

  context 'given a Yell::Level instance' do
    let(:level) { described_class.new(:warn) }

    it 'returns correctly' do
      expect(level).not_to be_at(:debug)
      expect(level).not_to be_at(:info)
      expect(level).to be_at(:warn)
      expect(level).to be_at(:error)
      expect(level).to be_at(:fatal)
    end
  end

  context 'backwards compatibility' do
    let(:level) { described_class.new :warn }

    it 'returns correctly to :to_i' do
      expect(level.to_i).to eq(2)
    end

    it 'typecasts with Integer correctly' do
      expect(Integer(level)).to eq(2)
    end

    it 'is compatible when passing to array (https://github.com/rudionrails/yell/issues/1)' do
      severities = %w[FINE INFO WARNING SEVERE SEVERE INFO]

      expect(severities[level]).to eq('WARNING')
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe Yell do
  subject { logger }

  let(:logger) { described_class.new }

  it 'be_kind_ofs Yell::Logger' do
    expect(subject).to be_a(Yell::Logger)
  end

  it 'raises AdapterNotFound when adapter cant be loaded' do
    expect do
      described_class.new :unknownadapter
    end.to raise_error(Yell::AdapterNotFound)
  end

  describe '.level' do
    subject { described_class.level }

    it 'be_kind_ofs Yell::Level' do
      expect(subject).to be_a(Yell::Level)
    end
  end

  describe '.format' do
    subject { described_class.format('%m') }

    it 'be_kind_ofs Yell::Formatter' do
      expect(subject).to be_a(Yell::Formatter)
    end
  end

  describe '.load!' do
    subject { described_class.load!('yell.yml') }

    before do
      expect(Yell::Configuration).to(
        receive(:load!).with('yell.yml').and_return({})
      )
    end

    it 'be_kind_ofs Yell::Logger' do
      expect(subject).to be_a(Yell::Logger)
    end
  end

  describe '.[]' do
    let(:name) { 'test' }

    it 'delegates to the repository' do
      expect(Yell::Repository).to receive(:[]).with(name)

      described_class[name]
    end
  end

  describe '.[]=' do
    let(:name) { 'test' }

    it 'delegates to the repository' do
      expect(Yell::Repository).to(
        receive(:[]=).with(name, logger).and_call_original
      )

      described_class[name] = logger
    end
  end

  describe '.env' do
    subject { described_class.env }

    it 'defaults to YELL_ENV' do
      expect(subject).to eq('test')
    end

    context 'fallback to RACK_ENV' do
      before do
        expect(ENV).to receive(:key?).with('YELL_ENV').and_return(false)
        expect(ENV).to receive(:key?).with('RACK_ENV').and_return(true)

        ENV['RACK_ENV'] = 'rack'
      end

      after { ENV.delete 'RACK_ENV' }

      it "==S 'rack'" do
        expect(subject).to eq('rack')
      end
    end

    context 'fallback to RAILS_ENV' do
      before do
        expect(ENV).to receive(:key?).with('YELL_ENV').and_return(false)
        expect(ENV).to receive(:key?).with('RACK_ENV').and_return(false)
        expect(ENV).to receive(:key?).with('RAILS_ENV').and_return(true)

        ENV['RAILS_ENV'] = 'rails'
      end

      after { ENV.delete 'RAILS_ENV' }

      it "==S 'rails'" do
        expect(subject).to eq('rails')
      end
    end

    context 'fallback to development' do
      before do
        expect(ENV).to receive(:key?).with('YELL_ENV').and_return(false)
        expect(ENV).to receive(:key?).with('RACK_ENV').and_return(false)
        expect(ENV).to receive(:key?).with('RAILS_ENV').and_return(false)
      end

      it "==S 'development'" do
        expect(subject).to eq('development')
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe Yell::Configuration do
  describe '.load!' do
    subject { config }

    let(:file) { "#{fixture_path}/yell.yml" }
    let(:config) { described_class.load!(file) }

    it { is_expected.to be_a(Hash) }
    it { is_expected.to have_key(:level) }
    it { is_expected.to have_key(:adapters) }

    context ':level' do
      subject { config[:level] }

      it { is_expected.to eq('info') }
    end

    context ':adapters' do
      subject { config[:adapters] }

      it { is_expected.to be_a(Array) }

      # stdout
      it { expect(subject.first).to eq(:stdout) }

      # stderr
      it { expect(subject.last).to be_a(Hash) }
      it { expect(subject.last).to eq(stderr: { level: 'gte.error' }) }
    end
  end
end

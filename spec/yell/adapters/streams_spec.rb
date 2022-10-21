# frozen_string_literal: true

require 'spec_helper'

describe Yell::Adapters::Stdout do
  it { is_expected.to be_a(Yell::Adapters::Io) }

  describe '#stream' do
    subject { described_class.new.send :stream }

    it { is_expected.to be_a(IO) }
  end
end

describe Yell::Adapters::Stderr do
  it { is_expected.to be_a(Yell::Adapters::Io) }

  describe '#stream' do
    subject { described_class.new.send(:stream) }

    it { is_expected.to be_a(IO) }
  end
end

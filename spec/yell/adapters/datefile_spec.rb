# frozen_string_literal: true

require 'spec_helper'

describe Yell::Adapters::Datefile do
  let(:logger) { Yell::Logger.new }
  let(:message) { 'Hello World' }
  let(:event) { Yell::Event.new(logger, 1, message) }

  let(:today) { Time.now }
  let(:tomorrow) { Time.now + 86_400 }

  let(:format) { '%m' }
  let(:filename) { "#{fixture_path}/test.log" }
  let(:today_filename) { fixture_path + "/test.#{today.strftime(Yell::Adapters::Datefile::DefaultDatePattern)}.log" }
  let(:tomorrow_filename) do
    fixture_path + "/test.#{tomorrow.strftime(Yell::Adapters::Datefile::DefaultDatePattern)}.log"
  end

  before do
    Timecop.freeze(today)
  end

  it { is_expected.to be_a Yell::Adapters::File }

  describe '#write' do
    let(:today_lines) { File.readlines(today_filename) }
    let(:adapter) { described_class.new(filename:, format:) }

    before do
      adapter.write(event)
    end

    it 'is output to filename with date pattern' do
      expect(File).to exist(today_filename)

      expect(today_lines.size).to eq(2) # includes header line
      expect(today_lines.last).to match(message)
    end

    it 'outputs to the same file' do
      adapter.write(event)

      expect(File).to exist(today_filename)
      expect(today_lines.size).to eq(3) # includes header line
    end

    it 'does not open file handle again' do
      expect(File).not_to receive(:open)

      adapter.write(event)
    end

    context 'on rollover' do
      let(:tomorrow_lines) { File.readlines(tomorrow_filename) }

      before do
        Timecop.freeze(tomorrow) { adapter.write(event) }
      end

      it 'rotates file' do
        expect(File).to exist(tomorrow_filename)

        expect(tomorrow_lines.size).to eq(2) # includes header line
        expect(tomorrow_lines.last).to match(message)
      end
    end
  end

  describe '#keep' do
    let(:adapter) { described_class.new(filename:, format:, symlink: false, keep: 2) }

    it 'keeps the specified number or files upon rollover' do
      adapter.write(event)
      expect(Dir["#{fixture_path}/*.log"].size).to eq(1)

      Timecop.freeze(tomorrow) { adapter.write(event) }
      expect(Dir["#{fixture_path}/*.log"].size).to eq(2)

      Timecop.freeze(tomorrow + 86_400) { adapter.write(event) }
      expect(Dir["#{fixture_path}/*.log"].size).to eq(2)
    end
  end

  describe '#symlink' do
    context 'when true (default)' do
      let(:adapter) { described_class.new(filename:, format:) }

      it 'is created on the original filename' do
        adapter.write(event)

        expect(File).to be_symlink(filename)
        expect(File.readlink(filename)).to eq(today_filename)
      end

      it 'is recreated upon rollover' do
        adapter.write(event)

        Timecop.freeze(tomorrow) { adapter.write(event) }

        expect(File).to be_symlink(filename)
        expect(File.readlink(filename)).to eq(tomorrow_filename)
      end
    end

    context 'when false' do
      let(:adapter) { described_class.new(filename:, format:, symlink: false) }

      it 'does not create the sylink the original filename' do
        adapter.write(event)

        expect(File).not_to be_symlink(filename)
      end
    end
  end

  describe '#header' do
    let(:header) { File.open(today_filename, &:readline) }

    context 'when true (default)' do
      let(:adapter) { described_class.new(filename:, format:) }

      it 'is written' do
        adapter.write(event)

        expect(header).to match(Yell::Adapters::Datefile::HeaderRegexp)
      end

      it 'is rewritten upon rollover' do
        adapter.write(event)

        Timecop.freeze(tomorrow) { adapter.write(event) }

        expect(File).to be_symlink(filename)
        expect(File.readlink(filename)).to eq(tomorrow_filename)
      end
    end

    context 'when false' do
      let(:adapter) { described_class.new(filename:, format:, header: false) }

      it 'is not written' do
        adapter.write(event)

        expect(header).to eq("Hello World\n")
      end
    end
  end

  context 'another adapter with the same :filename' do
    let(:adapter) { described_class.new(filename:, format:) }
    let(:another_adapter) { described_class.new(filename:) }

    before do
      adapter.write(event)
    end

    it 'does not write the header again' do
      another_adapter.write(event)

      # 1: header
      # 2: adapter write
      # 3: another_adapter: write
      expect(File.readlines(today_filename).size).to eq(3)
    end
  end
end

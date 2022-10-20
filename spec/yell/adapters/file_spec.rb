# frozen_string_literal: true

require 'spec_helper'

describe Yell::Adapters::File do
  let(:devnull) { File.new('/dev/null', 'w') }

  before do
    allow(File).to receive(:open) { devnull }
  end

  it { is_expected.to be_a(Yell::Adapters::Io) }

  describe '#stream' do
    subject { described_class.new.send(:stream) }

    it { is_expected.to be_a(File) }
  end

  describe '#write' do
    let(:logger) { Yell::Logger.new }
    let(:event) { Yell::Event.new(logger, 1, 'Hello World') }

    context 'default filename' do
      let(:filename) { File.expand_path "#{Yell.env}.log" }
      let(:adapter) { described_class.new }

      it 'prints to file' do
        expect(File).to(
          receive(:open)
            .with(filename, File::WRONLY | File::APPEND | File::CREAT) { devnull }
        )

        adapter.write(event)
      end
    end

    context 'with given :filename' do
      let(:filename) { "#{fixture_path}/filename.log" }
      let(:adapter) { described_class.new(filename: filename) }

      it 'prints to file' do
        expect(File).to(
          receive(:open)
            .with(filename, File::WRONLY | File::APPEND | File::CREAT) { devnull }
        )

        adapter.write(event)
      end
    end

    context 'with given :pathname' do
      let(:pathname) { Pathname.new(fixture_path).join('filename.log') }
      let(:adapter) { described_class.new(filename: pathname) }

      it 'accepts pathanme as filename' do
        expect(File).to(
          receive(:open)
            .with(pathname.to_s, File::WRONLY | File::APPEND | File::CREAT) { devnull }
        )

        adapter.write(event)
      end
    end

    describe '#sync' do
      let(:adapter) { described_class.new }

      it 'syncs by default' do
        expect(devnull).to receive(:sync=).with(true)

        adapter.write(event)
      end

      it 'pass the option to File' do
        adapter.sync = false

        expect(devnull).to receive(:sync=).with(false)

        adapter.write(event)
      end
    end
  end
end

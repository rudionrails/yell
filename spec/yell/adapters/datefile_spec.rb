require 'spec_helper'

describe Yell::Adapters::Datefile do
  let(:logger) { Yell::Logger.new }
  let(:message) { "Hello World" }
  let(:event) { Yell::Event.new(logger, 1, message) }

  let(:today) { Time.now }
  let(:tomorrow) { Time.now + 86400 }

  let(:filename) { fixture_path + '/test.log' }
  let(:today_filename) { fixture_path + "/test.#{today.strftime(Yell::Adapters::Datefile::DefaultDatePattern)}.log" }
  let(:tomorrow_filename) { fixture_path + "/test.#{tomorrow.strftime(Yell::Adapters::Datefile::DefaultDatePattern)}.log" }

  let(:adapter) { Yell::Adapters::Datefile.new(:filename => filename, :format => "%m") }

  before do
    Timecop.freeze(today)
  end

  it { should be_kind_of Yell::Adapters::File }

  describe :write do
    let(:today_lines) { File.readlines(today_filename) }

    before do
      adapter.write(event)
    end

    it "should be output to filename with date pattern" do
      File.exist?(today_filename).should be_true

      today_lines.size.should == 2 # includes header line
      today_lines.last.should match(message)
    end

    it "should output to the same file" do
      adapter.write(event)

      File.exist?(today_filename).should be_true
      today_lines.size.should == 3 # includes header line
    end

    it "should not open file handle again" do
      dont_allow(File).open(anything, anything)

      adapter.write(event)
    end

    context "on rollover" do
      let(:tomorrow_lines) { File.readlines(tomorrow_filename) }

      before do
        Timecop.freeze(tomorrow) { adapter.write(event) }
      end

      it "should rotate file" do
        File.exist?(tomorrow_filename).should be_true

        tomorrow_lines.size.should == 2 # includes header line
        tomorrow_lines.last.should match(message)
      end
    end
  end

  describe :keep do
    before do
      adapter.symlink = false # to not taint the Dir
      adapter.keep = 2

      adapter.write(event)
    end

    it "should keep the specified number or files upon rollover" do
      Dir[ fixture_path + '/*.log' ].size.should == 1

      Timecop.freeze(tomorrow) { adapter.write(event) }
      Dir[ fixture_path + '/*.log' ].size.should == 2

      Timecop.freeze(tomorrow + 86400 ) { adapter.write(event) }
      Dir[ fixture_path + '/*.log' ].size.should == 2
    end
  end

  describe :symlink do
    context "when true (default)" do
      before do
        adapter.write(event)
      end

      it "should be created on the original filename" do
        File.symlink?(filename).should be_true
        File.readlink(filename).should == today_filename
      end

      it "should be recreated upon rollover" do
        Timecop.freeze(tomorrow) { adapter.write(event) }

        File.symlink?(filename).should be_true
        File.readlink(filename).should == tomorrow_filename
      end
    end

    context "when false" do
      before do
        adapter.symlink = false
      end

      it "should not create the sylink the original filename" do
        adapter.write( event )

        File.symlink?(filename).should be_false
      end
    end
  end

  describe :header do
    let(:header) { File.open(today_filename, &:readline) }

    context "when true (default)" do
      before do
        adapter.write(event)
      end

      it "should be written" do
        header.should match(Yell::Adapters::Datefile::HeaderRegexp)
      end

      it "should be rewritten upon rollover" do
        Timecop.freeze(tomorrow) { adapter.write(event) }

        File.symlink?(filename).should be_true
        File.readlink(filename).should == tomorrow_filename
      end
    end

    context "when false" do
      before do
        adapter.header = false
      end

      it "should not be written" do
        adapter.write(event)

        header.should == "Hello World\n"
      end
    end
  end

  context "another adapter with the same :filename" do
    let(:another_adapter) { Yell::Adapters::Datefile.new(:filename => filename) }

    before do
      adapter.write(event)
    end

    it "should not write the header again" do
      another_adapter.write(event)

      # 1: header
      # 2: adapter write
      # 3: another_adapter: write
      File.readlines(today_filename).size.should == 3
    end
  end

end


require 'spec_helper'

describe Yell::Adapters::File do
  let( :devnull ) { File.new('/dev/null', 'w') }

  before do
    stub( File ).open( anything, anything ) { devnull }
  end

  it { should be_kind_of Yell::Adapters::Io }

  context :stream do
    subject { Yell::Adapters::File.new.send :stream }

    it { should be_kind_of File }
  end

  context :write do
    let( :event ) { Yell::Event.new(1, "Hello World") }

    context "default filename" do
      let( :filename ) { File.expand_path "#{Yell.env}.log" }
      let( :adapter ) { Yell::Adapters::File.new }

      it "should print to file" do
        mock( File ).open( filename, File::WRONLY|File::APPEND|File::CREAT ) { devnull }

        adapter.write( event )
      end
    end

    context "with given filename" do
      let( :filename ) { fixture_path + '/filename.log' }
      let( :adapter ) { Yell::Adapters::File.new( :filename => filename ) }

      it "should print to file" do
        mock( File ).open( filename, File::WRONLY|File::APPEND|File::CREAT ) { devnull }

        adapter.write( event )
      end
    end

    context :sync do
      let( :adapter ) { Yell::Adapters::File.new }

      it "should sync by default" do
        any_instance_of( File ) do |file|
          mock( file ).sync=( true )
        end

        adapter.write( event )
      end

      it "pass the option to File" do
        adapter.sync = false

        any_instance_of( File ) do |file|
          mock( file ).sync=( false )
        end

        adapter.write( event )
      end
    end
  end

end


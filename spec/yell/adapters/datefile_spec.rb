require 'spec_helper'

describe Yell::Adapters::Datefile do
  let( :time ) { Time.now }
  let( :filename ) { 'filename.log' }

  let( :event ) { Yell::Event.new("INFO", "Hello World") }

  describe :filename do
    let( :adapter ) { Yell::Adapters::Datefile.new(:filename => filename) }
    let( :date_filename ) { "filename.#{time.strftime(Yell::Adapters::Datefile::DefaultDatePattern)}.log" }

    before do
      Timecop.freeze( time )
    end

    it "should be replaced with date_pattern" do
      adapter.write( event )

      File.exist?(date_filename).should be_true
    end

    it "should open file handle only once" do
      mock( File ).open( date_filename, anything ) { File.new('/dev/null', 'w') }

      adapter.write( event )
      adapter.write( event )
    end

    context "rollover" do
      let( :tomorrow ) { time + 86400 }
      let( :tomorrow_date_filename ) { "filename.#{tomorrow.strftime(Yell::Adapters::Datefile::DefaultDatePattern)}.log" }

      it "should rollover when date has passed" do
        mock( File ).open( date_filename, anything ) { File.new('/dev/null', 'w') }
        adapter.write( event )

        Timecop.freeze( tomorrow ) # tomorrow

        mock( File ).open( tomorrow_date_filename, anything ) { File.new('/dev/null', 'w') }
        adapter.write( event )
      end
    end
  end
end

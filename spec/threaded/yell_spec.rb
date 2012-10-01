require 'spec_helper'

describe "running Yell multi-threaded" do
  let( :threads ) { 100 }

  let( :filename ) { fixture_path + '/threaded.log' }
  let( :lines ) { `wc -l #{filename}`.to_i }

  it "should write all messages from one instance" do
    logger = Yell.new( filename )

    (1..threads).map do |count|
      Thread.new { 10.times { logger.info count } }
    end.each(&:join)

    lines.should == 10*threads
  end

  # it "should write all messages from multiple instances" do
  #   (1..threads).map do |count|
  #     Thread.new do
  #       logger = Yell.new( filename )

  #       10.times { logger.info count }
  #     end
  #   end.each(&:join)

  #   lines.should == 10*threads
  # end

  it "should write all messages from one repository" do
    Yell[ 'threaded' ] = Yell.new( filename )

    (1..threads).map do |count|
      Thread.new { 10.times { Yell['threaded'].info count } }
    end.each(&:join)

    lines.should == 10*threads
  end

  it "should safely rollover with multiple datefile instances" do
    date = Time.now
    Timecop.travel( date - 86400 )

    t = (1..threads).map do |count|
      Thread.new do
        logger = Yell.new :datefile, :filename => filename, :keep => 2
        loop { logger.info :info; sleep 0.1 }
      end
    end

    sleep 0.3 # sleep to get some messages into the file

    # now cycle the days
    14.times do |count|
      Timecop.travel( date + 86400*count )
      sleep 0.3

      Dir[ fixture_path + '/*.log' ].size.should == 2
    end

    t.each(&:kill)
  end

end


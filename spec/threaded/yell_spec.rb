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

end


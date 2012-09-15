require 'spec_helper'

describe Yell::Level do

  context "default" do
    let( :level ) { Yell::Level.new }

    it { level.at?(:debug).should be_true }
    it { level.at?(:info).should be_true }
    it { level.at?(:warn).should be_true }
    it { level.at?(:error).should be_true }
    it { level.at?(:fatal).should be_true }
  end

  context "given a Symbol" do
    let( :level ) { Yell::Level.new(subject) }

    context :debug do
      subject { :debug }

      it { level.at?(:debug).should be_true }
      it { level.at?(:info).should be_true }
      it { level.at?(:warn).should be_true }
      it { level.at?(:error).should be_true }
      it { level.at?(:fatal).should be_true }
    end

    context :info do
      subject { :info }

      it { level.at?(:debug).should be_false }
      it { level.at?(:info).should be_true }
      it { level.at?(:warn).should be_true }
      it { level.at?(:error).should be_true }
      it { level.at?(:fatal).should be_true }
    end

    context :warn do
      subject { :warn }

      it { level.at?(:debug).should be_false }
      it { level.at?(:info).should be_false }
      it { level.at?(:warn).should be_true }
      it { level.at?(:error).should be_true }
      it { level.at?(:fatal).should be_true }
    end

    context :error do
      subject { :error }

      it { level.at?(:debug).should be_false }
      it { level.at?(:info).should be_false }
      it { level.at?(:warn).should be_false }
      it { level.at?(:error).should be_true }
      it { level.at?(:fatal).should be_true }
    end

    context :fatal do
      subject { :fatal }

      it { level.at?(:debug).should be_false }
      it { level.at?(:info).should be_false }
      it { level.at?(:warn).should be_false }
      it { level.at?(:error).should be_false }
      it { level.at?(:fatal).should be_true }
    end
  end

  context "given a String" do
    let( :level ) { Yell::Level.new(subject) }

    context "basic string" do
      subject { 'error' }

      it "should be valid" do
        level.at?(:debug).should be_false
        level.at?(:info).should be_false
        level.at?(:warn).should be_false
        level.at?(:error).should be_true
        level.at?(:fatal).should be_true
      end
    end

    context "complex string with outer boundaries" do
      subject { 'gte.info lte.error' }

      it "should be valid" do
        level.at?(:debug).should be_false
        level.at?(:info).should be_true
        level.at?(:warn).should be_true
        level.at?(:error).should be_true
        level.at?(:fatal).should be_false
      end
    end

    context "complex string with inner boundaries" do
      subject { 'gt.info lt.error' }

      it "should be valid" do
        level.at?(:debug).should be_false
        level.at?(:info).should be_false
        level.at?(:warn).should be_true
        level.at?(:error).should be_false
        level.at?(:fatal).should be_false
      end
    end

    context "complex string with precise boundaries" do
      subject { 'at.info at.error' }

      it "should be valid" do
        level.at?(:debug).should be_false
        level.at?(:info).should be_true
        level.at?(:warn).should be_false
        level.at?(:error).should be_true
        level.at?(:fatal).should be_false
      end
    end

    context "complex string with combined boundaries" do
      subject { 'gte.error at.debug' }

      it "should be valid" do
        level.at?(:debug).should be_true
        level.at?(:info).should be_false
        level.at?(:warn).should be_false
        level.at?(:error).should be_true
        level.at?(:fatal).should be_true
      end
    end
  end

  context "given an Array" do
    let( :level ) { Yell::Level.new( [:debug, :warn, :fatal] ) }

    it { level.at?(:debug).should be_true }
    it { level.at?(:info).should be_false }
    it { level.at?(:warn).should be_true }
    it { level.at?(:error).should be_false }
    it { level.at?(:fatal).should be_true }
  end

  context "given a Range" do
    let( :level ) { Yell::Level.new( (1..3) ) }

    it { level.at?(:debug).should be_false }
    it { level.at?(:info).should be_true }
    it { level.at?(:warn).should be_true }
    it { level.at?(:error).should be_true }
    it { level.at?(:fatal).should be_false }
  end

  context "given a Yell::Level instance" do
    let( :level ) { Yell::Level.new( :warn ) }

    it { level.at?(:debug).should be_false }
    it { level.at?(:info).should be_false }
    it { level.at?(:warn).should be_true }
    it { level.at?(:error).should be_true }
    it { level.at?(:fatal).should be_true }
  end

  context "backwards compatibility" do
    let( :level ) { Yell::Level.new :warn }

    it { level.to_i.should == 2 }
    it { Integer(level).should == 2 }

    it "should be compatible when passing to array (https://github.com/rudionrails/yell/issues/1)" do
      severities = %w(FINE INFO WARNING SEVERE SEVERE INFO)

      severities[level].should == "WARNING"
    end
  end
end

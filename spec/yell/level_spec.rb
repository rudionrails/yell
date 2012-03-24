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

  context "given an Array" do
    let( :level ) { Yell::Level.new(subject) }

    subject { [:debug, :warn, :fatal] }

    it { level.at?(:debug).should be_true }
    it { level.at?(:info).should be_false }
    it { level.at?(:warn).should be_true }
    it { level.at?(:error).should be_false }
    it { level.at?(:fatal).should be_true }
  end

  context "given a Range" do
    let( :level ) { Yell::Level.new(subject) }

    subject { (1..3) }

    it { level.at?(:debug).should be_false }
    it { level.at?(:info).should be_true }
    it { level.at?(:warn).should be_true }
    it { level.at?(:error).should be_true }
    it { level.at?(:fatal).should be_false }
  end

end

require 'spec_helper'

describe Yell::Silencer do

  context "initialize with #patterns" do
    subject { Yell::Silencer.new(/this/) }

    its(:patterns) { should eq([/this/]) }
  end

  context "#add" do
    let(:silencer) { Yell::Silencer.new }

    it "should add patterns" do
      silencer.add /this/, /that/

      expect(silencer.patterns).to eq([/this/, /that/])
    end

    it "should ignore duplicate patterns" do
      silencer.add /this/, /that/, /this/

      expect(silencer.patterns).to eq([/this/, /that/])
    end
  end

  context "#silence?" do
    let(:silencer) { Yell::Silencer.new }

    it "should be false when no patterns present" do
      expect(silencer.silence?).to be_false
    end

    it "should be true when patterns present" do
      silencer.add /this/

      expect(silencer.silence?).to be_true
    end
  end

  context "#silence" do
    let(:silencer) { Yell::Silencer.new(/this/) }

    it "should reject messages that match any pattern" do
      expect(silencer.silence("this")).to be_nil
      expect(silencer.silence("that")).to eq("that")
    end
  end

end

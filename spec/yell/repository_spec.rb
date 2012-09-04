require 'spec_helper'

describe Yell::Repository do
  let( :name ) { 'test' }
  let( :logger ) { Yell.new :stdout }

  subject { Yell[name] }


  context ".[]" do
    context "when not set" do
      it { should be_nil }
    end

    context "when assigned" do
      before do
        Yell[ name ] = logger
      end

      it { should == logger }
    end
  end

  context ".[]=" do
    before do
      Yell[ name ] = logger
    end

    it { should == logger }
  end

end


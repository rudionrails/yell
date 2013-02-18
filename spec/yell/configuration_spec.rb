require 'spec_helper'

describe Yell::Configuration do

  describe ":load!" do
    let(:file) { fixture_path + '/yell.yml' }
    let(:config) { Yell::Configuration.load!(file) }

    subject { config }

    it { should be_kind_of(Hash) }
    it { should have_key(:level) }
    it { should have_key(:adapters) }

    context :level do
      subject { config[:level] }

      it { should == "info" }
    end

    context :adapters do
      subject { config[:adapters] }

      it { should be_kind_of(Array) }

      # stdout
      it { subject.first.should == :stdout }

      # stderr
      it { subject.last.should be_kind_of(Hash) }
      it { subject.last.should == { :stderr => {:level => 'gte.error'} } }
    end
  end

end


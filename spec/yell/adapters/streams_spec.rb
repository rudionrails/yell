require 'spec_helper'

describe Yell::Adapters::Stdout do

  it { should be_kind_of Yell::Adapters::Io }

  context :stream do
    subject { Yell::Adapters::Stdout.new.stream }

    it { should be_kind_of IO }
  end

end

describe Yell::Adapters::Stderr do

  it { should be_kind_of Yell::Adapters::Io }

  context :stream do
    subject { Yell::Adapters::Stderr.new.stream }

    it { should be_kind_of IO }
  end

end


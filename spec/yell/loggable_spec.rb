require 'spec_helper'

class LoggableFactory
  include Yell::Loggable
end

describe Yell::Loggable do
  subject { LoggableFactory.new }

  it { should respond_to :logger }

  it ":logger should pass class name to the repository" do
    mock( Yell::Repository )[ LoggableFactory ]

    subject.logger
  end

end


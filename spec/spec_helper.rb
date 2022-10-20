# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path(__dir__)
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

ENV['YELL_ENV'] = 'test'

require 'rspec'
require 'timecop'

begin
  require 'byebug'
rescue LoadError
  # do nothing when not available
end

begin
  require 'coveralls'
  require 'simplecov'

  warn 'Running coverage...'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                   SimpleCov::Formatter::HTMLFormatter,
                                                                   Coveralls::SimpleCov::Formatter
                                                                 ])

  SimpleCov.start do
    add_filter 'spec'
  end
rescue LoadError
  # do nothing when not available
end

require 'yell'

RSpec.configure do |config|
  # allow running only focussed specs
  #
  # it 'runs a test', :focus do
  #   ...test code
  # end
  config.filter_run_when_matching :focus

  # # Disable RSpec exposing methods globally on `Module` and `main`
  # config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    Yell::Repository.loggers.clear

    Dir["#{fixture_path}/*.log"].each { |f| File.delete f }
  end

  config.after do
    Timecop.return # release time after each test
  end

  private

  def fixture_path
    File.expand_path('fixtures', File.dirname(__FILE__)).to_s
  end
end

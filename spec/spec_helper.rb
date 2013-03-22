$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

ENV['YELL_ENV'] = 'test'

require 'rspec'
require 'rr'
require 'timecop'

require 'simplecov'
require 'coveralls'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'yell'

RSpec.configure do |config|
  config.mock_framework = :rr

  config.before do
    Yell::Repository.loggers.clear

    Dir[ fixture_path + "/*.log" ].each { |f| File.delete f }
  end

  config.after do
    # release time after each test
    Timecop.return
  end


  private

  def fixture_path
    File.expand_path( "fixtures", File.dirname(__FILE__) )
  end

end


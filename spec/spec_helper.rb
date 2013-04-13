$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

ENV['YELL_ENV'] = 'test'

require 'rspec'
require 'rr'
require 'timecop'

begin
  require 'coveralls'

  require 'simplecov'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start
rescue LoadError
  STDERR.puts "Not running coverage..."
end

require 'yell'

RSpec.configure do |config|
  config.mock_framework = :rr

  config.before do
    Yell::Repository.loggers.clear

    Dir[ fixture_path + "/*.log" ].each { |f| File.delete f }
  end

  config.after do
    Timecop.return # release time after each test
  end


  private

  def fixture_path
    File.expand_path( "fixtures", File.dirname(__FILE__) )
  end

end


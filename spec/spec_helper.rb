$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

ENV['YELL_ENV'] = 'test'

require 'yell'

require 'rspec'
require 'rr'
require 'timecop'

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

  def datefile_filename( pattern = Yell::Adapters::Datefile::DefaultDatePattern )
    fixture_path + "/test.#{Time.now.strftime(pattern)}.log"
  end

end


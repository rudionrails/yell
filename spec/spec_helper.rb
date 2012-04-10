$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'ostruct'

require 'yell'

require 'rspec'
require 'rr'
require 'timecop'

RSpec.configure do |config|
  config.mock_framework = :rr

  config.after do
    Dir[ "*.log" ].each { |f| File.delete f }
  end
end


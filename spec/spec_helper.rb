$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'yell'

require 'rspec'
require 'timecop'

RSpec.configure do |config|

  config.before do
    Yell.config.stub!( :yaml_file ).and_return( File.dirname(__FILE__) + '/config/yell.yml' )
  end

  config.after do
    Yell.config.reload! # to not run into caching problems during tests
  end

end


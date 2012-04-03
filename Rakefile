$LOAD_PATH.unshift( 'lib' )

require 'bundler'
Bundler::GemHelper.install_tasks

task :examples do
  puts "**** Running Examples"
  Dir[ File.dirname(__FILE__) + '/examples/*.rb' ].each { |file| require file }
end

# === RSpec
begin
  require 'rspec/core/rake_task'

  desc "Run specs"
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = %w(--color --format progress --order random)
    t.ruby_opts = %w(-w)
  end
rescue LoadError
  task :spec do
    abort "`gem install rspec` in order to run tests"
  end
end

task :default => :spec


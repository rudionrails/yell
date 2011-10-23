$LOAD_PATH.unshift( 'lib' )

require 'bundler'
Bundler::GemHelper.install_tasks

# === RSpec
require 'rspec/core/rake_task'

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(-fs --color)
end

task :default => :spec


# === Rdoc
require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "inventory #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

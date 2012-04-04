$LOAD_PATH.unshift( 'lib' )

require 'bundler'
Bundler::GemHelper.install_tasks

task :examples do
  Dir[ './examples/*.rb' ].each do |file|
    begin
      puts "**** Running #{file}"

      require file
    rescue Exception => e
      puts "#{e.class}: #{e.message}:\n\t#{e.backtrace.join("\n\t")}"

      exit 1
    end
  end
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


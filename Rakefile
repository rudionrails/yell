$LOAD_PATH.unshift( 'lib' )

require 'bundler'
Bundler::GemHelper.install_tasks

task :examples do
  require 'benchmark'

  seconds = Benchmark.realtime do
    Dir[ './examples/*.rb' ].sort.each do |file|
      begin
        puts "\n*** Running #{file}"

        require file
      rescue Exception => e
        puts "#{e.class}: #{e.message}:\n\t#{e.backtrace.join("\n\t")}"

        exit 1
      end
    end
  end

  puts "\n\t[ Examples took #{seconds} seconds to run ]"
end

# RSpec
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


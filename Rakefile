# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

# Run stuff in the examples folder
desc "Run examples"
task :examples do
  require 'benchmark'

  seconds = Benchmark.realtime do
    Dir[ './examples/*.rb' ].each { |file| puts "\n\n=== Running #{file} ==="; require file }
  end

  puts "\n\t[ Examples took #{seconds} seconds to run ]"
end


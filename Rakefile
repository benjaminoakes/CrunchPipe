
require "rubygems"
require "bundler/setup"

require 'rake'
require 'rspec/core/rake_task'

task :default => :spec

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--format documentation --color'
end

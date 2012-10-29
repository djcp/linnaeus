# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "linnaeus"
  gem.homepage = "http://github.com/djcp/linnaeus"
  gem.license = "MIT"
  gem.summary = %Q{Another redis-backed Bayesian classifier}
  gem.description = %Q{Linnaeus provides a redis-backed Bayesian classifier. Words are stemmed, stopwords are stopped, and redis is used to allow for persistent and concurrent training and classification.}
  gem.email = "dan@collispuro.net"
  gem.authors = ["djcp"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new

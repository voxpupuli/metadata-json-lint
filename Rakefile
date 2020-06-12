desc 'Run all tests'
task :test => %i[rubocop spec test:acceptance]

require 'rubocop/rake_task'
RuboCop::RakeTask.new

namespace :test do
  desc 'Acceptance suite under test/ which runs metadata-json-lint against sample files with expected output'
  task :acceptance do
    sh 'tests/test.sh'
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

begin
  require 'github_changelog_generator/task'

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.header = "# Changelog\n\nAll notable changes to this project will be documented in this file."
    config.exclude_labels = %w[duplicate question invalid wontfix wont-fix skip-changelog]
    config.user = 'voxpupuli'
    config.project = 'metadata-json-lint'
    config.future_release = "v#{Gem::Specification.load("#{config.project}.gemspec").version}"
  end
rescue LoadError
  puts 'no github_changelog_generator gem available'
end

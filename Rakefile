desc 'Run all tests'
task test: %i[spec test:acceptance]

begin
  require 'rubocop/rake_task'
rescue LoadError
  # RuboCop is an optional group
else
  RuboCop::RakeTask.new(:rubocop) do |task|
    # These make the rubocop experience maybe slightly less terrible
    task.options = ['--display-cop-names', '--display-style-guide', '--extra-details']
    # Use Rubocop's Github Actions formatter if possible
    task.formatters << 'github' if ENV['GITHUB_ACTIONS'] == 'true'
  end
end

namespace :test do
  desc 'Acceptance suite under test/ which runs metadata-json-lint against sample files with expected output'
  task :acceptance do
    sh 'tests/test.sh'
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

begin
  require 'rubygems'
  require 'github_changelog_generator/task'
rescue LoadError
  # github_changelog_generator is in the optional `release` group
else
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.exclude_labels = %w[duplicate question invalid wontfix wont-fix skip-changelog github_actions]
    config.user = 'voxpupuli'
    config.project = 'metadata-json-lint'
    gem_version = Gem::Specification.load("#{config.project}.gemspec").version
    config.future_release = gem_version
  end
end

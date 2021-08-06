desc 'Run all tests'
task :test => %i[rubocop spec test:acceptance]

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |task|
  # These make the rubocop experience maybe slightly less terrible
  task.options = ['-D', '-S', '-E']

  # Use Rubocop's Github Actions formatter if possible
  if ENV['GITHUB_ACTIONS'] == 'true'
    rubocop_spec = Gem::Specification.find_by_name('rubocop')
    if Gem::Version.new(rubocop_spec.version) >= Gem::Version.new('1.2')
      task.formatters << 'github'
    end
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
rescue LoadError # rubocop:disable Lint/HandleExceptions
else
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.exclude_labels = %w[duplicate question invalid wontfix wont-fix skip-changelog]
    config.user = 'voxpupuli'
    config.project = 'metadata-json-lint'
    gem_version = Gem::Specification.load("#{config.project}.gemspec").version
    config.future_release = gem_version
  end
end

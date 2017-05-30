desc 'Run all tests'
task :test => %i[rubocop test:acceptance]

require 'rubocop/rake_task'
RuboCop::RakeTask.new

namespace :test do
  desc 'Acceptance suite under test/ which runs metadata-json-lint against sample files with expected output'
  task :acceptance do
    sh 'tests/test.sh'
  end
end

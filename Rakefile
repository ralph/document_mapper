# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
task default: :test
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/**/*_test.rb']
  t.ruby_opts = ['-Itest']
end

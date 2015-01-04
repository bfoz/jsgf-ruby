require 'bundler/gem_tasks'
require 'rake/testtask'

rule '.rb' => '.y' do |t|
    `racc -l -o #{t.name} #{t.source}`
end

task :default => :test
task compile: 'lib/jsgf/parser.rb'

Rake::TestTask.new(:test => :compile) do |t|
    t.libs.push "lib"
    t.test_files = FileList['test/**/*.rb']
    t.verbose = true
end
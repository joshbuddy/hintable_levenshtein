libdir = File.expand_path("lib")
$:.unshift(libdir) unless $:.include?(libdir)

require 'hintable_levenshtein'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "hintable_levenshtein"
    s.description = s.summary = "Levenshtein with hints"
    s.email = "joshbuddy@gmail.com"
    s.homepage = "http://github.com/joshbuddy/hintable_levenshtein"
    s.authors = ["Joshua Hull"]
    s.files = FileList["[A-Z]*", "{lib,spec}/**/*"]
    s.rubyforge_project = 'joshbuddy-hintable_levenshtein'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

require 'spec'
require 'spec/rake/spectask'
task :spec => 'spec:all'
namespace(:spec) do
  Spec::Rake::SpecTask.new(:all) do |t|
    t.spec_opts ||= []
    t.spec_opts << "-rubygems"
    t.spec_opts << "--options" << "spec/spec.opts"
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('spec_with_rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

require 'rake/rdoctask'
desc "Generate documentation"
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = 'rdoc'
end

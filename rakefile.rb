require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
#require 'rake/clean'

$: << 'lib'

require 'OSM'

task :default => :test

desc "Run the tests"
Rake::TestTask::new do |t|
    t.test_files = FileList['test/test_*.rb']
    t.verbose = true
end

desc 'Measures test coverage'
task :rcov do
    rm_f "coverage"
    system("rcov test/test_*rb")
end

desc "Generate the documentation"
Rake::RDocTask::new do |rdoc|
    rdoc.rdoc_dir = 'rdoc/'
    rdoc.title    = "OSM Library Documentation - Base"
    rdoc.options << '--line-numbers' << '--inline-source'
    rdoc.rdoc_files = FileList['README.txt', 'examples/README.txt', 'lib/**/*.rb']
end

spec = Gem::Specification::new do |s|
    s.platform = Gem::Platform::RUBY

    s.name = 'osmlib-base'
    s.version = OSM::VERSION
    s.summary = 'Library for basic OpenStreetMap data handling'
    s.description = <<EOF
Basic support for OpenStreetMap data model (Nodes, Ways, Relations and Tags). Parsing of OSM XML files. Access to OpenStreetMap API.
EOF
    s.author = 'Jochen Topf'
    s.email = 'jochen@topf.org'
    s.homepage = 'osmlib.rubyforge.org'
    s.rubyforge_project = 'osmlib'
    
    s.require_path = 'lib'
    s.test_files = FileList['test/test*.rb']

    s.has_rdoc = true
    s.extra_rdoc_files = ['README.txt', 'examples/README.txt']

    s.files = FileList['lib/**/*.rb', 'LICENSE', 'rakefile.rb', 'examples/*'] + s.test_files + s.extra_rdoc_files
    s.rdoc_options.concat ['--main',  'README.txt']

    # commented out because this doesn't work when libxml-ruby is installed as a Debian package
    #s.add_dependency('libxml-ruby')
end

desc "Package the library as a gem"
Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
end


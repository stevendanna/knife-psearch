$:.unshift(File.dirname(__FILE__) + '/lib')
require 'knife-psearch/version'

Gem::Specification.new do |s|
  s.name = 'knife-psearch'
  s.version = KnifePSearch::VERSION
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["LICENSE" ]
  s.summary = "Knife Plugin for Chef 11's Partial Search"
  s.description = s.summary
  s.author = "Steven Danna"
  s.email = "steve@opscode.com"
  s.homepage = "http://wiki.opscode.com/display/chef"
  s.require_path = 'lib'
  s.files = %w(LICENSE) + Dir.glob("lib/**/*")
end

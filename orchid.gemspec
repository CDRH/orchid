$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "orchid/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "orchid"
  s.version     = Orchid::VERSION
  s.authors     = ["Jessica Dussault", "Greg Tunink", "Karin Dalziel"]
  s.email       = ["jdussault4@gmail.com", "techgique@gmail.com", "kdalziel@unl.edu"]
  s.homepage    = "https://cdrh.unl.edu"
  s.summary     = "Template for Pando sites"
  s.description = "Template for sites powered off of Pando API"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.0.rc1"
  s.add_dependency "colorize"

  s.add_development_dependency "sqlite3"
end

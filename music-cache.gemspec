# -*- encoding: utf-8 -*-
require File.expand_path("../lib/music-cache/version", __FILE__)

Gem::Specification.new do |s|
  s.name          = "music-cache"
  s.version       = MusicCache::VERSION
  s.platform      = Gem::Platform::RUBY
  s.summary       = %Q{Index, analyze and repair your music collection}
  s.description   = %Q{Index, analyze and repair your music collection}
  s.email         = "andrew.hay.kurtz@gmail.com"
  s.homepage      = "http://github.com/gzuki/music-cache"
  s.authors       = ["Andrew Hay Kurtz"]

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "music-cache"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "consular-iterm"
  s.version     = "1.0.3"
  s.authors     = ["Arthur Chiu"]
  s.email       = ["mr.arthur.chiu@gmail.com"]
  s.homepage    = "http://www.github.com/achiu/consular-iterm"
  s.summary     = %q{Automate your ITerm with Consular}
  s.description = %q{Terminal Automation for ITerm via Consular}

  s.rubyforge_project = "consular-iterm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'consular'
  s.add_dependency 'rb-scpt'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'mocha'

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end

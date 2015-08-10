# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'html/pipeline/hashtag/version'

Gem::Specification.new do |spec|
  spec.name          = "html-pipeline-hashtag"
  spec.version       = Html::Pipeline::Hashtag::VERSION
  spec.authors       = ["German Antsiferov"]
  spec.email         = ["dxdy@bk.ru"]

  spec.summary       = %q{HTML Pipeline filter that replaces hashtags with links.}
  spec.description   = %q{HTML Pipeline filter that replaces hashtags with links.}
  spec.homepage      = "https://github.com/mr-dxdy/html-pipeline-hashtag"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'html-pipeline', '~> 1.11.0'

  spec.add_development_dependency "rspec", '~> 3.2.0'
  spec.add_development_dependency "github-markdown",    "~> 0.5"
end

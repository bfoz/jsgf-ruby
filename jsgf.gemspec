# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
    spec.name          = "jsgf"
    spec.version       = '0.4.1'
    spec.authors       = ["Brandon Fosdick"]
    spec.email         = ["bfoz@bfoz.net"]
    spec.summary       = %q{Java Speech Grammar Format}
    spec.description   = %q{A parser and DSL for JSGF files}
    spec.homepage      = "http://github.com/bfoz/jsgf-ruby"
    spec.license       = "BSD"

    spec.files         = `git ls-files -z`.split("\x0").push('lib/jsgf/parser.rb').reject {|f| File.basename(f) == 'parser.y'}
    spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
    spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
    spec.require_paths = ["lib"]

    spec.add_development_dependency "bundler", "~> 1.7"
    spec.add_development_dependency "rake", "~> 10.0"
end

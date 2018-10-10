
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cc/version"

Gem::Specification.new do |spec|
  spec.name          = "cc"
  spec.version       = Cc::VERSION
  spec.authors       = ["Kat Padilla"]
  spec.email         = ["hello@katpadi.ph"]

  spec.summary       = %q{Cc is a PDF credit card statement parser and converter.}
  spec.description   = %q{Cc is a PDF credit card statement parser and converter. It converts PDF statements to a meaningful CSV or JSON. The JSON file can be rendered in a dynatable in http://foo.katpadi.ph/}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "awesome_print"

  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency "json", "~> 2.1.0"
  spec.add_dependency "pdf-reader", "~> 2.1.0"
  spec.add_dependency "smarter_csv", "~> 1.2.5"
end


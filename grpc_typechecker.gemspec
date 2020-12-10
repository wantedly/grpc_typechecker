require_relative 'lib/grpc_typechecker/version'

Gem::Specification.new do |spec|
  spec.name          = "grpc_typechecker"
  spec.version       = GrpcTypechecker::VERSION
  spec.authors       = ["Masayuki Mizuno"]
  spec.email         = ["mizuno@wantedly.com"]

  spec.summary       = "A dynamic type checker for gRPC methods"
  spec.description   = "A dynamic type checker for gRPC methods"
  spec.homepage      = "https://github.com/wantedly/grpc_typechecker"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/wantedly/grpc_typechecker"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'grpc'
  spec.add_dependency 'activesupport'
  spec.add_development_dependency 'rspec'
end

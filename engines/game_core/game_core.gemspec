# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name        = "game_core"
  spec.version     = "0.1.0"
  spec.authors     = ["Rock Paper Scissors Team"]
  spec.summary     = "Core game domain logic for Rock Paper Scissors"
  spec.description = "A Rails Engine containing the domain layer for Rock Paper Scissors game logic. " \
                     "Implements DDD patterns including Value Objects, Domain Services, and Registry Pattern."

  spec.license = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,lib}/**/*", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.2.0"

  spec.add_dependency "rails", ">= 7.0"
end

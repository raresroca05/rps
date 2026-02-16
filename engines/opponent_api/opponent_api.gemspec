# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name        = "opponent_api"
  spec.version     = "0.1.0"
  spec.authors     = [ "Rock Paper Scissors Team" ]
  spec.summary     = "Opponent API integration for Rock Paper Scissors"
  spec.description = "A Rails Engine providing opponent throw generation via external APIs " \
                     "with fallback strategies. Implements Strategy Pattern for swappable providers."

  spec.license = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,lib}/**/*", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = ">= 3.2.0"

  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "game_core" # Depends on core domain
end

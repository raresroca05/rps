# frozen_string_literal: true

require "game_core/engine"

module GameCore
  # Core game domain module
  # Contains all business logic for Rock Paper Scissors
  #
  # Architecture:
  #   - Domain::Throw      - Value Object representing a game throw
  #   - Domain::Rules      - Registry/Repository for game rules
  #   - Domain::Resolver   - Domain Service for determining outcomes
  #   - Domain::Result     - Value Object representing game result
end

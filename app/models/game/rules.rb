# frozen_string_literal: true

module Game
  # Backward-compatible alias for GameCore::Domain::Rules
  # Delegates to the engine's implementation
  #
  # @see GameCore::Domain::Rules for the actual implementation
  #
  Rules = GameCore::Domain::Rules
end

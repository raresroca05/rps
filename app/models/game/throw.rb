# frozen_string_literal: true

module Game
  # Backward-compatible alias for GameCore::Domain::Throw
  # Delegates to the engine's implementation
  #
  # This pattern allows gradual migration to the engine architecture
  # while maintaining API compatibility with existing code.
  #
  # @see GameCore::Domain::Throw for the actual implementation
  #
  Throw = GameCore::Domain::Throw
end

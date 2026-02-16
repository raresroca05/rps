# frozen_string_literal: true

module Game
  # Backward-compatible alias for GameCore::Domain::Resolver
  # Delegates to the engine's implementation
  #
  # @see GameCore::Domain::Resolver for the actual implementation
  #
  Resolver = GameCore::Domain::Resolver
end

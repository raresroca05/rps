# frozen_string_literal: true

require "opponent_api/engine"

module OpponentApi
  # Opponent API integration module
  # Provides opponent throw generation with resilient external API integration
  #
  # Architecture:
  #   - Client           - Facade for fetching opponent throws
  #   - Strategies::Base - Abstract strategy interface
  #   - Strategies::Http - HTTP API strategy with retry logic
  #   - Strategies::Fallback - Local random generation strategy
  #   - Result           - Value Object for API response
  #
  # Design Patterns:
  #   - Strategy Pattern: Swappable opponent generation strategies
  #   - Facade Pattern: Client provides simple interface to complex subsystem
  #   - Template Method: Base strategy defines algorithm structure

  class << self
    # Configure the default strategy
    # @param strategy [Symbol] :http or :fallback
    def configure_strategy(strategy)
      @default_strategy = strategy
    end

    # Get the default strategy
    # @return [Symbol]
    def default_strategy
      @default_strategy || :http
    end
  end
end

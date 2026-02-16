# frozen_string_literal: true

module OpponentApi
  module Strategies
    # Fallback Strategy for generating opponent throws locally
    #
    # Design Pattern: Strategy Pattern
    # - Implements the Strategy interface for local random generation
    # - Used when HTTP strategy fails or for offline mode
    # - Always succeeds (no external dependencies)
    #
    # SOLID Principles:
    # - Single Responsibility: Only handles local random generation
    # - Liskov Substitution: Fully interchangeable with Http strategy
    #
    class Fallback < Base
      protected

      def perform_fetch
        throw_name = GameCore::Domain::Rules.random_throw
        fallback_result(throw_name)
      end
    end
  end
end

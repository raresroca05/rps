# frozen_string_literal: true

module GameCore
  module Domain
    # Domain Service that resolves game outcomes
    #
    # DDD Pattern: Domain Service
    # - Stateless operation that doesn't belong to an entity
    # - Orchestrates domain objects (Throw, Rules) to produce Result
    # - Pure function: same inputs always produce same outputs
    #
    # Design Pattern: Factory Method (creates Result objects)
    #
    # SOLID Principles:
    # - Single Responsibility: Only resolves game outcomes
    # - Open/Closed: Works with any throws in Rules registry
    # - Dependency Inversion: Depends on Rules abstraction
    #
    # @example Resolving a game
    #   resolver = GameCore::Domain::Resolver.new(
    #     player_throw: "rock",
    #     opponent_throw: "scissors"
    #   )
    #   resolver.result.win? # => true
    #
    # @example Using class method
    #   result = GameCore::Domain::Resolver.resolve(
    #     player_throw: "rock",
    #     opponent_throw: "scissors"
    #   )
    #
    class Resolver
      attr_reader :player_throw, :opponent_throw, :result

      # Class method for one-shot resolution
      # @param player_throw [String, Symbol, Throw] player's throw
      # @param opponent_throw [String, Symbol, Throw] opponent's throw
      # @return [Result] the game result
      def self.resolve(player_throw:, opponent_throw:)
        new(player_throw: player_throw, opponent_throw: opponent_throw).result
      end

      # @param player_throw [String, Symbol, Throw] player's throw
      # @param opponent_throw [String, Symbol, Throw] opponent's throw
      def initialize(player_throw:, opponent_throw:)
        @player_throw = ensure_throw(player_throw)
        @opponent_throw = ensure_throw(opponent_throw)
        @result = build_result
      end

      # Convenience delegation to result
      def outcome
        @result.outcome
      end

      def win?
        @result.win?
      end

      def lose?
        @result.lose?
      end

      def tie?
        @result.tie?
      end

      def result_message
        @result.message
      end

      private

      def build_result
        Result.new(
          player_throw: @player_throw,
          opponent_throw: @opponent_throw,
          outcome: determine_outcome
        )
      end

      def determine_outcome
        return :tie if @player_throw == @opponent_throw
        return :win if @player_throw.beats?(@opponent_throw)

        :lose
      end

      def ensure_throw(value)
        value.is_a?(Throw) ? value : Throw.new(value)
      end
    end
  end
end

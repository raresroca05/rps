# frozen_string_literal: true

module GameCore
  module Domain
    # Value Object representing the result of a game
    #
    # DDD Pattern: Value Object
    # - Immutable representation of a game outcome
    # - Contains both the outcome and the context (throws)
    # - Self-describing with helper methods
    #
    # SOLID Principles:
    # - Single Responsibility: Only represents a game result
    # - Interface Segregation: Provides multiple ways to query outcome
    #
    # @example Creating a result
    #   result = GameCore::Domain::Result.new(
    #     player_throw: throw1,
    #     opponent_throw: throw2,
    #     outcome: :win
    #   )
    #   result.win? # => true
    #
    class Result
      VALID_OUTCOMES = %i[win lose tie].freeze

      attr_reader :player_throw, :opponent_throw, :outcome

      # @param player_throw [Throw] the player's throw
      # @param opponent_throw [Throw] the opponent's throw
      # @param outcome [Symbol] :win, :lose, or :tie
      # @raise [ArgumentError] if outcome is invalid
      def initialize(player_throw:, opponent_throw:, outcome:)
        @player_throw = player_throw
        @opponent_throw = opponent_throw
        @outcome = validate_outcome!(outcome)
        freeze # Immutability
      end

      # @return [Boolean] true if player won
      def win?
        @outcome == :win
      end

      # @return [Boolean] true if player lost
      def lose?
        @outcome == :lose
      end

      # @return [Boolean] true if game was a tie
      def tie?
        @outcome == :tie
      end

      # Human-readable result message
      # @return [String]
      def message
        case @outcome
        when :win  then "You win!"
        when :lose then "You lose!"
        when :tie  then "It's a tie!"
        end
      end

      # Value Object equality
      # @param other [Result]
      # @return [Boolean]
      def ==(other)
        return false unless other.is_a?(Result)

        player_throw == other.player_throw &&
          opponent_throw == other.opponent_throw &&
          outcome == other.outcome
      end

      alias eql? ==

      def hash
        [ player_throw, opponent_throw, outcome ].hash
      end

      private

      def validate_outcome!(outcome)
        outcome_sym = outcome.to_sym
        return outcome_sym if VALID_OUTCOMES.include?(outcome_sym)

        raise ArgumentError,
              "Invalid outcome: #{outcome}. Valid outcomes: #{VALID_OUTCOMES.join(', ')}"
      end
    end
  end
end

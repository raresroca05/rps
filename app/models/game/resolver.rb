# frozen_string_literal: true

module Game
  # Determines the outcome of a game between two throws
  # Returns :win, :lose, or :tie from the perspective of player1
  class Resolver
    attr_reader :player_throw, :opponent_throw, :outcome

    def initialize(player_throw:, opponent_throw:)
      @player_throw = ensure_throw(player_throw)
      @opponent_throw = ensure_throw(opponent_throw)
      @outcome = resolve
    end

    def win?
      @outcome == :win
    end

    def lose?
      @outcome == :lose
    end

    def tie?
      @outcome == :tie
    end

    def result_message
      case @outcome
      when :win then "You win!"
      when :lose then "You lose!"
      when :tie then "It's a tie!"
      end
    end

    private

    def resolve
      return :tie if @player_throw == @opponent_throw
      return :win if @player_throw.beats?(@opponent_throw)

      :lose
    end

    def ensure_throw(value)
      value.is_a?(Throw) ? value : Throw.new(value)
    end
  end
end

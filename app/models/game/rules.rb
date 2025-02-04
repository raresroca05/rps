# frozen_string_literal: true

module Game
  # Registry defining game rules - what beats what
  # Designed for extensibility: adding new throws requires only updating RULES
  class Rules
    # Each key is a throw, and its value is an array of throws it beats
    RULES = {
      rock: [:scissors],
      paper: [:rock],
      scissors: [:paper]
    }.freeze

    class << self
      # Get all valid throw names
      def throws
        RULES.keys
      end

      # Check if a throw name is valid
      def valid_throw?(name)
        RULES.key?(name.to_sym)
      end

      # Check if throw1 beats throw2
      def beats?(throw1, throw2)
        throw1 = throw1.to_sym
        throw2 = throw2.to_sym

        RULES[throw1]&.include?(throw2) || false
      end

      # Get what a specific throw beats
      def what_beats(throw_name)
        RULES[throw_name.to_sym] || []
      end

      # Get a random throw (used for fallback)
      def random_throw
        throws.sample
      end
    end
  end
end

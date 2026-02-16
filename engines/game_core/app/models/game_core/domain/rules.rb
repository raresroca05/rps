# frozen_string_literal: true

module GameCore
  module Domain
    # Registry/Repository for game rules defining what beats what
    #
    # DDD Pattern: Domain Service + Repository
    # - Acts as a repository for game rules
    # - Provides domain operations on rules
    #
    # Design Pattern: Registry Pattern
    # - Single source of truth for all game rules
    # - Adding new throws only requires updating RULES hash
    #
    # SOLID Principles:
    # - Single Responsibility: Only manages game rules
    # - Open/Closed: New throws added via data, not code changes
    # - Liskov Substitution: All throws behave consistently
    # - Interface Segregation: Minimal, focused API
    # - Dependency Inversion: Other classes depend on this abstraction
    #
    # @example Checking if a throw beats another
    #   Rules.beats?(:rock, :scissors) # => true
    #   Rules.beats?(:rock, :paper)    # => false
    #
    # @example Adding a new throw (Lizard-Spock variant)
    #   # Just update the RULES hash:
    #   RULES = {
    #     rock: [:scissors, :lizard],
    #     paper: [:rock, :spock],
    #     scissors: [:paper, :lizard],
    #     lizard: [:paper, :spock],
    #     spock: [:rock, :scissors]
    #   }.freeze
    #
    class Rules
      # Registry: Each key is a throw, value is array of throws it defeats
      # This is the ONLY place game rules are defined
      RULES = {
        rock: [ :scissors ],
        paper: [ :rock, :hammer ],
        scissors: [ :paper ],
        hammer: [ :scissors, :rock ]
      }.freeze

      # Standard throws that external APIs typically support
      STANDARD_THROWS = %i[rock paper scissors].freeze

      class << self
        # Get all valid throw names
        # @return [Array<Symbol>] list of valid throws
        def throws
          RULES.keys
        end

        # Get only standard throws (for API compatibility)
        # @return [Array<Symbol>] list of standard throws
        def standard_throws
          STANDARD_THROWS
        end

        # Check if a throw name is valid
        # @param name [String, Symbol] throw name to validate
        # @return [Boolean]
        def valid_throw?(name)
          RULES.key?(name.to_sym)
        end

        # Check if throw1 beats throw2
        # @param throw1 [String, Symbol] the attacking throw
        # @param throw2 [String, Symbol] the defending throw
        # @return [Boolean]
        def beats?(throw1, throw2)
          attacker = throw1.to_sym
          defender = throw2.to_sym

          RULES[attacker]&.include?(defender) || false
        end

        # Get what a specific throw defeats
        # @param throw_name [String, Symbol] the throw to query
        # @return [Array<Symbol>] throws that are defeated
        def defeats(throw_name)
          RULES[throw_name.to_sym] || []
        end

        # Alias for backward compatibility
        alias what_beats defeats

        # Get a random standard throw (for fallback scenarios)
        # Only returns standard throws to match typical API behavior
        # @return [Symbol] a random standard throw
        def random_throw
          STANDARD_THROWS.sample
        end

        # Get all rules (for introspection/debugging)
        # @return [Hash] frozen copy of rules
        def all
          RULES.dup.freeze
        end
      end
    end
  end
end

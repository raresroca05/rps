# frozen_string_literal: true

module GameCore
  module Domain
    # Value Object representing a game throw (rock, paper, scissors, etc.)
    #
    # DDD Pattern: Value Object
    # - Immutable after creation
    # - Equality based on attributes, not identity
    # - Self-validating (fail-fast)
    #
    # SOLID Principles:
    # - Single Responsibility: Only represents a throw concept
    # - Open/Closed: Extensible via Rules registry without modification
    #
    # @example Creating a valid throw
    #   throw = GameCore::Domain::Throw.new("rock")
    #   throw.name # => :rock
    #
    # @example Invalid throw raises error (fail-fast)
    #   GameCore::Domain::Throw.new("invalid") # => ArgumentError
    #
    class Throw
      attr_reader :name

      # @param name [String, Symbol] the throw name
      # @raise [ArgumentError] if throw is not in Rules registry
      def initialize(name)
        @name = normalize(name)
        validate!
        freeze # Immutability - Value Objects should be frozen
      end

      # @return [String] string representation
      def to_s
        @name.to_s
      end

      # @return [Symbol] symbol representation
      def to_sym
        @name
      end

      # Value Object equality - based on attributes
      # @param other [Throw] another throw to compare
      # @return [Boolean]
      def ==(other)
        return false unless other.is_a?(Throw)

        @name == other.name
      end

      alias eql? ==

      # Hash code for use in Hash keys and Sets
      # @return [Integer]
      def hash
        @name.hash
      end

      # Domain logic: Check if this throw beats another
      # Delegates to Rules registry (Dependency Inversion)
      # @param other [Throw] the opponent's throw
      # @return [Boolean]
      def beats?(other)
        Rules.beats?(@name, other.name)
      end

      private

      def normalize(name)
        name.to_s.downcase.to_sym
      end

      def validate!
        return if Rules.valid_throw?(@name)

        raise ArgumentError,
              "Invalid throw: #{@name}. Valid throws: #{Rules.throws.join(', ')}"
      end
    end
  end
end

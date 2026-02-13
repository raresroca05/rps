# frozen_string_literal: true

module Game
  # Value object representing a game throw (rock, paper, scissors, etc.)
  # Validates that the throw is in the allowed set defined by Rules
  class Throw
    attr_reader :name

    def initialize(name)
      @name = name.to_s.downcase.to_sym
      validate!
    end

    def to_s
      @name.to_s
    end

    def to_sym
      @name
    end

    def ==(other)
      return false unless other.is_a?(Throw)

      @name == other.name
    end

    alias eql? ==

    def hash
      @name.hash
    end

    # Check if this throw beats another throw
    def beats?(other)
      Rules.beats?(@name, other.name)
    end

    private

    def validate!
      unless Rules.valid_throw?(@name)
        raise ArgumentError, "Invalid throw: #{@name}. Valid throws are: #{Rules.throws.join(', ')}"
      end
    end
  end
end

# frozen_string_literal: true

module OpponentApi
  # Value Object representing the result of fetching an opponent's throw
  #
  # DDD Pattern: Value Object
  # - Immutable representation of API response
  # - Tracks source for transparency (API vs fallback)
  #
  # @example
  #   result = OpponentApi::Result.new(throw_name: :rock, source: :api)
  #   result.api? # => true
  #
  class Result
    VALID_SOURCES = %i[api fallback].freeze

    attr_reader :throw_name, :source

    # @param throw_name [Symbol] the opponent's throw
    # @param source [Symbol] :api or :fallback
    def initialize(throw_name:, source:)
      @throw_name = throw_name.to_sym
      @source = validate_source!(source)
      freeze
    end

    # @return [Boolean] true if throw came from API
    def api?
      @source == :api
    end

    # @return [Boolean] true if throw was generated locally
    def fallback?
      @source == :fallback
    end

    # Value Object equality
    def ==(other)
      return false unless other.is_a?(Result)

      throw_name == other.throw_name && source == other.source
    end

    alias eql? ==

    def hash
      [throw_name, source].hash
    end

    private

    def validate_source!(source)
      source_sym = source.to_sym
      return source_sym if VALID_SOURCES.include?(source_sym)

      raise ArgumentError, "Invalid source: #{source}. Valid: #{VALID_SOURCES.join(', ')}"
    end
  end
end

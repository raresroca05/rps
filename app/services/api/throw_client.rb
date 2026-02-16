# frozen_string_literal: true

module Api
  # Backward-compatible wrapper for OpponentApi::Client
  # Maintains the same API as the original ThrowClient
  #
  # This adapter pattern allows gradual migration to the engine
  # while keeping existing controller and test code unchanged.
  #
  # @see OpponentApi::Client for the actual implementation
  #
  class ThrowClient
    # Result struct matching the original API
    Result = Struct.new(:throw_name, :source, keyword_init: true) do
      def api?
        source == :api
      end

      def fallback?
        source == :fallback
      end
    end

    class << self
      def fetch
        # Delegate to engine and convert result to legacy format
        engine_result = OpponentApi::Client.fetch
        Result.new(
          throw_name: engine_result.throw_name,
          source: engine_result.source
        )
      end
    end

    # Instance method support for backward compatibility
    def fetch
      self.class.fetch
    end

    class ApiError < StandardError; end
  end
end

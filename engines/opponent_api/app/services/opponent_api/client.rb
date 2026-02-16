# frozen_string_literal: true

module OpponentApi
  # Facade for fetching opponent throws with automatic fallback
  #
  # Design Pattern: Facade Pattern
  # - Provides simple interface to the strategy subsystem
  # - Handles strategy selection and fallback logic
  # - Clients don't need to know about strategies
  #
  # Design Pattern: Chain of Responsibility (fallback chain)
  # - HTTP strategy tries first
  # - Fallback strategy handles failures
  #
  # SOLID Principles:
  # - Single Responsibility: Orchestrates strategies
  # - Open/Closed: New strategies added without changing client
  # - Dependency Inversion: Depends on strategy abstractions
  #
  # @example Basic usage
  #   result = OpponentApi::Client.fetch
  #   result.throw_name # => :rock
  #   result.api?       # => true or false
  #
  # @example With specific strategy
  #   client = OpponentApi::Client.new(strategy: :fallback)
  #   result = client.fetch
  #
  class Client
    STRATEGIES = {
      http: Strategies::Http,
      fallback: Strategies::Fallback
    }.freeze

    class << self
      # Convenience method for one-shot fetch with default strategy
      # @return [Result]
      def fetch
        new.fetch
      end

      # Register a custom strategy
      # @param name [Symbol] strategy identifier
      # @param klass [Class] strategy class (must inherit from Strategies::Base)
      def register_strategy(name, klass)
        unless klass < Strategies::Base
          raise ArgumentError, "Strategy must inherit from Strategies::Base"
        end

        STRATEGIES[name.to_sym] = klass
      end
    end

    # @param strategy [Symbol] :http or :fallback (or custom registered)
    # @param fallback_on_error [Boolean] whether to fallback on strategy failure
    def initialize(strategy: nil, fallback_on_error: true)
      @strategy_name = strategy || OpponentApi.default_strategy
      @fallback_on_error = fallback_on_error
      @strategy = build_strategy(@strategy_name)
    end

    # Fetch an opponent's throw
    # @return [Result]
    def fetch
      @strategy.fetch
    rescue StandardError => e
      handle_strategy_error(e)
    end

    private

    def build_strategy(name)
      klass = STRATEGIES[name.to_sym]
      raise ArgumentError, "Unknown strategy: #{name}" unless klass

      klass.new
    end

    def handle_strategy_error(error)
      if @fallback_on_error && @strategy_name != :fallback
        Rails.logger.warn(
          "[OpponentApi::Client] #{@strategy_name} failed: #{error.message}. Using fallback."
        )
        Strategies::Fallback.new.fetch
      else
        raise error
      end
    end
  end
end

# frozen_string_literal: true

module OpponentApi
  module Strategies
    # Abstract base class for opponent throw strategies
    #
    # Design Pattern: Strategy Pattern + Template Method
    # - Defines the interface for all opponent strategies
    # - Template Method: #fetch defines algorithm, subclasses implement #perform_fetch
    #
    # SOLID Principles:
    # - Liskov Substitution: All strategies are interchangeable
    # - Interface Segregation: Minimal required interface
    # - Dependency Inversion: Client depends on this abstraction
    #
    # @abstract Subclass and implement #perform_fetch
    #
    class Base
      # Fetch an opponent's throw
      # Template Method: wraps subclass implementation with error handling
      # @return [Result] the opponent's throw with source tracking
      def fetch
        perform_fetch
      rescue StandardError => e
        handle_error(e)
      end

      protected

      # @abstract Subclasses must implement this
      # @return [Result]
      def perform_fetch
        raise NotImplementedError, "#{self.class} must implement #perform_fetch"
      end

      # @abstract Subclasses may override error handling
      # @param error [StandardError]
      def handle_error(error)
        Rails.logger.error("[#{self.class.name}] Error: #{error.message}")
        raise error
      end

      # Helper to create successful API result
      # @param throw_name [Symbol]
      # @return [Result]
      def api_result(throw_name)
        Result.new(throw_name: throw_name, source: :api)
      end

      # Helper to create fallback result
      # @param throw_name [Symbol]
      # @return [Result]
      def fallback_result(throw_name)
        Result.new(throw_name: throw_name, source: :fallback)
      end
    end
  end
end

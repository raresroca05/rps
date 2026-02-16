# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module OpponentApi
  module Strategies
    # HTTP Strategy for fetching opponent throws from external API
    #
    # Design Pattern: Strategy Pattern
    # - Implements the Strategy interface for HTTP-based opponent fetching
    # - Can be swapped with other strategies (Fallback, Mock, etc.)
    #
    # Resilience Patterns:
    # - Timeout configuration (connect + read)
    # - Automatic retry with configurable attempts
    # - Graceful error handling
    #
    # SOLID Principles:
    # - Single Responsibility: Only handles HTTP communication
    # - Open/Closed: Configuration via engine config, not code changes
    #
    class Http < Base
      class ApiError < StandardError; end

      def initialize(
        api_url: nil,
        connect_timeout: nil,
        read_timeout: nil,
        max_retries: nil
      )
        super()
        @api_url = api_url || config.api_url
        @connect_timeout = connect_timeout || config.connect_timeout
        @read_timeout = read_timeout || config.read_timeout
        @max_retries = max_retries || config.max_retries
      end

      protected

      def perform_fetch
        retries = 0

        begin
          response = make_request
          throw_name = parse_response(response)
          validate_throw!(throw_name)

          api_result(throw_name.to_sym)
        rescue StandardError => e
          if retries < @max_retries
            retries += 1
            Rails.logger.info("[#{self.class.name}] Retry #{retries}/#{@max_retries} after: #{e.message}")
            retry
          end
          raise
        end
      end

      private

      def config
        OpponentApi::Engine.config.http_client
      end

      def make_request
        uri = URI.parse(@api_url)
        http = build_http_client(uri)
        request = build_request(uri)
        http.request(request)
      end

      def build_http_client(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        # Skip SSL verification due to API certificate issues
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.open_timeout = @connect_timeout
        http.read_timeout = @read_timeout
        http
      end

      def build_request(uri)
        request = Net::HTTP::Get.new(uri.request_uri)
        request["User-Agent"] = "RockPaperScissors/1.0"
        request["Accept"] = "application/json"
        request
      end

      def parse_response(response)
        unless response.is_a?(Net::HTTPSuccess)
          raise ApiError, "HTTP #{response.code}: #{response.message}"
        end

        data = JSON.parse(response.body)

        if data["statusCode"] == 500
          raise ApiError, "API error: #{data['body']}"
        end

        data["body"]
      end

      def validate_throw!(throw_name)
        return if GameCore::Domain::Rules.valid_throw?(throw_name)

        raise ApiError, "Invalid throw from API: #{throw_name}"
      end
    end
  end
end

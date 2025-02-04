# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Api
  # HTTP client for fetching opponent throws from external API
  # Falls back to random local throw on failure
  class ThrowClient
    API_URL = "https://5eddt4q9dk.execute-api.us-east-1.amazonaws.com/rps-stage/throw"
    CONNECT_TIMEOUT = 5
    READ_TIMEOUT = 10
    MAX_RETRIES = 1

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
        new.fetch
      end
    end

    def fetch
      retries = 0

      begin
        response = make_request
        throw_name = parse_response(response)
        validate_throw!(throw_name)

        Result.new(throw_name: throw_name.to_sym, source: :api)
      rescue StandardError => e
        if retries < MAX_RETRIES
          retries += 1
          retry
        end

        Rails.logger.warn("API request failed, using fallback: #{e.message}")
        fallback_result
      end
    end

    private

    def make_request
      uri = URI.parse(API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = CONNECT_TIMEOUT
      http.read_timeout = READ_TIMEOUT

      request = Net::HTTP::Get.new(uri.request_uri)
      http.request(request)
    end

    def parse_response(response)
      unless response.is_a?(Net::HTTPSuccess)
        raise ApiError, "HTTP #{response.code}: #{response.message}"
      end

      data = JSON.parse(response.body)

      if data["statusCode"] == 500
        raise ApiError, "API returned error: #{data['body']}"
      end

      data["body"]
    end

    def validate_throw!(throw_name)
      unless Game::Rules.valid_throw?(throw_name)
        raise ApiError, "Invalid throw received from API: #{throw_name}"
      end
    end

    def fallback_result
      Result.new(throw_name: Game::Rules.random_throw, source: :fallback)
    end

    class ApiError < StandardError; end
  end
end

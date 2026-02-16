# frozen_string_literal: true

module OpponentApi
  class Engine < ::Rails::Engine
    isolate_namespace OpponentApi

    # Ensure game_core is loaded first
    config.before_initialize do
      require "game_core"
    end

    config.generators do |g|
      g.test_framework :rspec
    end

    # Configuration for HTTP client
    config.http_client = ActiveSupport::OrderedOptions.new
    config.http_client.connect_timeout = 5
    config.http_client.read_timeout = 10
    config.http_client.max_retries = 1
    config.http_client.api_url = "https://5eddt4q9dk.execute-api.us-east-1.amazonaws.com/rps-stage/throw"
  end
end

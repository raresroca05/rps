# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe Api::ThrowClient do
  let(:api_url) { "https://5eddt4q9dk.execute-api.us-east-1.amazonaws.com/rps-stage/throw" }

  describe "#fetch" do
    context "when API returns success" do
      it "returns the throw from API" do
        stub_request(:get, api_url)
          .to_return(
            status: 200,
            body: { statusCode: 200, body: "rock" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        result = Api::ThrowClient.fetch

        expect(result.throw_name).to eq(:rock)
        expect(result.api?).to be true
        expect(result.fallback?).to be false
      end

      it "handles paper response" do
        stub_request(:get, api_url)
          .to_return(
            status: 200,
            body: { statusCode: 200, body: "paper" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        result = Api::ThrowClient.fetch
        expect(result.throw_name).to eq(:paper)
      end

      it "handles scissors response" do
        stub_request(:get, api_url)
          .to_return(
            status: 200,
            body: { statusCode: 200, body: "scissors" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        result = Api::ThrowClient.fetch
        expect(result.throw_name).to eq(:scissors)
      end
    end

    context "when API returns error status code" do
      it "falls back to random throw on HTTP 500" do
        stub_request(:get, api_url)
          .to_return(status: 500, body: "Internal Server Error")

        result = Api::ThrowClient.fetch

        expect(Game::Rules.throws).to include(result.throw_name)
        expect(result.fallback?).to be true
      end

      it "falls back when statusCode in body is 500" do
        stub_request(:get, api_url)
          .to_return(
            status: 200,
            body: { statusCode: 500, body: "Something went wrong" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        result = Api::ThrowClient.fetch

        expect(Game::Rules.throws).to include(result.throw_name)
        expect(result.fallback?).to be true
      end
    end

    context "when API times out" do
      it "falls back to random throw after retries" do
        stub_request(:get, api_url).to_timeout

        result = Api::ThrowClient.fetch

        expect(Game::Rules.throws).to include(result.throw_name)
        expect(result.fallback?).to be true
      end
    end

    context "when API returns invalid JSON" do
      it "falls back to random throw" do
        stub_request(:get, api_url)
          .to_return(status: 200, body: "not json")

        result = Api::ThrowClient.fetch

        expect(Game::Rules.throws).to include(result.throw_name)
        expect(result.fallback?).to be true
      end
    end

    context "when API returns invalid throw" do
      it "falls back to random throw" do
        stub_request(:get, api_url)
          .to_return(
            status: 200,
            body: { statusCode: 200, body: "invalid_throw" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        result = Api::ThrowClient.fetch

        expect(Game::Rules.throws).to include(result.throw_name)
        expect(result.fallback?).to be true
      end
    end

    context "when network error occurs" do
      it "falls back to random throw" do
        stub_request(:get, api_url).to_raise(SocketError.new("Connection refused"))

        result = Api::ThrowClient.fetch

        expect(Game::Rules.throws).to include(result.throw_name)
        expect(result.fallback?).to be true
      end
    end
  end
end

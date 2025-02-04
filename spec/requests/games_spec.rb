# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe "Games", type: :request do
  let(:api_url) { "https://5eddt4q9dk.execute-api.us-east-1.amazonaws.com/rps-stage/throw" }

  describe "GET /games (index)" do
    it "renders successfully" do
      get games_path
      expect(response).to have_http_status(:success)
    end

    it "displays throw options" do
      get games_path
      expect(response.body).to include("rock")
      expect(response.body).to include("paper")
      expect(response.body).to include("scissors")
    end
  end

  describe "GET / (root)" do
    it "renders the games index" do
      get root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Rock Paper Scissors")
    end
  end

  describe "POST /games/play" do
    before do
      stub_request(:get, api_url)
        .to_return(
          status: 200,
          body: { statusCode: 200, body: "rock" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "renders result page" do
      post play_games_path, params: { throw: "paper" }
      expect(response).to have_http_status(:success)
    end

    it "displays player throw" do
      post play_games_path, params: { throw: "scissors" }
      expect(response.body).to include("scissors")
    end

    it "displays opponent throw" do
      post play_games_path, params: { throw: "paper" }
      expect(response.body).to include("rock")
    end

    it "displays game result for win" do
      post play_games_path, params: { throw: "paper" }
      expect(response.body).to include("You win!")
    end

    it "displays game result for loss" do
      stub_request(:get, api_url)
        .to_return(
          status: 200,
          body: { statusCode: 200, body: "paper" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      post play_games_path, params: { throw: "rock" }
      expect(response.body).to include("You lose!")
    end

    it "displays game result for tie" do
      post play_games_path, params: { throw: "rock" }
      expect(response.body).to include("tie")
    end

    context "with invalid throw" do
      it "redirects to root with error" do
        post play_games_path, params: { throw: "invalid" }
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Invalid throw")
      end
    end

    context "when API fails" do
      it "uses fallback and completes game" do
        stub_request(:get, api_url).to_timeout

        post play_games_path, params: { throw: "rock" }
        expect(response).to have_http_status(:success)
        expect(response.body).to include("offline mode")
      end
    end
  end
end

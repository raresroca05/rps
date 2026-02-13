# frozen_string_literal: true

require "rails_helper"

RSpec.describe Game::Resolver do
  describe "game outcomes" do
    context "when player wins" do
      it "rock beats scissors" do
        result = Game::Resolver.new(player_throw: :rock, opponent_throw: :scissors)
        expect(result.outcome).to eq(:win)
        expect(result.win?).to be true
        expect(result.lose?).to be false
        expect(result.tie?).to be false
      end

      it "scissors beats paper" do
        result = Game::Resolver.new(player_throw: :scissors, opponent_throw: :paper)
        expect(result.outcome).to eq(:win)
      end

      it "paper beats rock" do
        result = Game::Resolver.new(player_throw: :paper, opponent_throw: :rock)
        expect(result.outcome).to eq(:win)
      end
    end

    context "when player loses" do
      it "rock loses to paper" do
        result = Game::Resolver.new(player_throw: :rock, opponent_throw: :paper)
        expect(result.outcome).to eq(:lose)
        expect(result.win?).to be false
        expect(result.lose?).to be true
        expect(result.tie?).to be false
      end

      it "scissors loses to rock" do
        result = Game::Resolver.new(player_throw: :scissors, opponent_throw: :rock)
        expect(result.outcome).to eq(:lose)
      end

      it "paper loses to scissors" do
        result = Game::Resolver.new(player_throw: :paper, opponent_throw: :scissors)
        expect(result.outcome).to eq(:lose)
      end
    end

    context "when it's a tie" do
      it "rock ties rock" do
        result = Game::Resolver.new(player_throw: :rock, opponent_throw: :rock)
        expect(result.outcome).to eq(:tie)
        expect(result.win?).to be false
        expect(result.lose?).to be false
        expect(result.tie?).to be true
      end

      it "paper ties paper" do
        result = Game::Resolver.new(player_throw: :paper, opponent_throw: :paper)
        expect(result.outcome).to eq(:tie)
      end

      it "scissors ties scissors" do
        result = Game::Resolver.new(player_throw: :scissors, opponent_throw: :scissors)
        expect(result.outcome).to eq(:tie)
      end
    end
  end

  describe "#result_message" do
    it "returns 'You win!' for wins" do
      result = Game::Resolver.new(player_throw: :rock, opponent_throw: :scissors)
      expect(result.result_message).to eq("You win!")
    end

    it "returns 'You lose!' for losses" do
      result = Game::Resolver.new(player_throw: :rock, opponent_throw: :paper)
      expect(result.result_message).to eq("You lose!")
    end

    it "returns 'It's a tie!' for ties" do
      result = Game::Resolver.new(player_throw: :rock, opponent_throw: :rock)
      expect(result.result_message).to eq("It's a tie!")
    end
  end

  describe "throw objects" do
    it "accepts Throw objects" do
      player = Game::Throw.new(:rock)
      opponent = Game::Throw.new(:scissors)
      result = Game::Resolver.new(player_throw: player, opponent_throw: opponent)
      expect(result.win?).to be true
    end

    it "stores Throw objects" do
      result = Game::Resolver.new(player_throw: :rock, opponent_throw: :paper)
      expect(result.player_throw).to be_a(Game::Throw)
      expect(result.opponent_throw).to be_a(Game::Throw)
    end
  end
end

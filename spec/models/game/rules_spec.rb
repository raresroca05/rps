# frozen_string_literal: true

require "rails_helper"

RSpec.describe Game::Rules do
  describe ".throws" do
    it "returns all valid throw names" do
      expect(Game::Rules.throws).to contain_exactly(:rock, :paper, :scissors)
    end
  end

  describe ".valid_throw?" do
    it "returns true for valid throws" do
      expect(Game::Rules.valid_throw?(:rock)).to be true
      expect(Game::Rules.valid_throw?(:paper)).to be true
      expect(Game::Rules.valid_throw?(:scissors)).to be true
    end

    it "returns true for string input" do
      expect(Game::Rules.valid_throw?("rock")).to be true
    end

    it "returns false for invalid throws" do
      expect(Game::Rules.valid_throw?(:invalid)).to be false
      expect(Game::Rules.valid_throw?(:hammer)).to be false
    end
  end

  describe ".beats?" do
    it "rock beats scissors" do
      expect(Game::Rules.beats?(:rock, :scissors)).to be true
    end

    it "scissors beats paper" do
      expect(Game::Rules.beats?(:scissors, :paper)).to be true
    end

    it "paper beats rock" do
      expect(Game::Rules.beats?(:paper, :rock)).to be true
    end

    it "rock does not beat paper" do
      expect(Game::Rules.beats?(:rock, :paper)).to be false
    end

    it "scissors does not beat rock" do
      expect(Game::Rules.beats?(:scissors, :rock)).to be false
    end

    it "paper does not beat scissors" do
      expect(Game::Rules.beats?(:paper, :scissors)).to be false
    end

    it "same throw does not beat itself" do
      expect(Game::Rules.beats?(:rock, :rock)).to be false
    end

    it "accepts string input" do
      expect(Game::Rules.beats?("rock", "scissors")).to be true
    end
  end

  describe ".what_beats" do
    it "returns what rock beats" do
      expect(Game::Rules.what_beats(:rock)).to eq([:scissors])
    end

    it "returns what paper beats" do
      expect(Game::Rules.what_beats(:paper)).to eq([:rock])
    end

    it "returns what scissors beats" do
      expect(Game::Rules.what_beats(:scissors)).to eq([:paper])
    end

    it "returns empty array for invalid throw" do
      expect(Game::Rules.what_beats(:invalid)).to eq([])
    end
  end

  describe ".random_throw" do
    it "returns a valid throw" do
      10.times do
        expect(Game::Rules.throws).to include(Game::Rules.random_throw)
      end
    end
  end
end

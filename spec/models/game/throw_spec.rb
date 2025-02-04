# frozen_string_literal: true

require "rails_helper"

RSpec.describe Game::Throw do
  describe "#initialize" do
    it "creates a throw with a valid name" do
      throw = Game::Throw.new(:rock)
      expect(throw.name).to eq(:rock)
    end

    it "normalizes string input to symbol" do
      throw = Game::Throw.new("Rock")
      expect(throw.name).to eq(:rock)
    end

    it "raises ArgumentError for invalid throw" do
      expect { Game::Throw.new(:invalid) }.to raise_error(ArgumentError, /Invalid throw/)
    end
  end

  describe "#to_s" do
    it "returns the throw name as a string" do
      throw = Game::Throw.new(:paper)
      expect(throw.to_s).to eq("paper")
    end
  end

  describe "#to_sym" do
    it "returns the throw name as a symbol" do
      throw = Game::Throw.new(:scissors)
      expect(throw.to_sym).to eq(:scissors)
    end
  end

  describe "#==" do
    it "returns true for throws with the same name" do
      throw1 = Game::Throw.new(:rock)
      throw2 = Game::Throw.new(:rock)
      expect(throw1).to eq(throw2)
    end

    it "returns false for throws with different names" do
      throw1 = Game::Throw.new(:rock)
      throw2 = Game::Throw.new(:paper)
      expect(throw1).not_to eq(throw2)
    end

    it "returns false when compared with non-Throw objects" do
      throw = Game::Throw.new(:rock)
      expect(throw).not_to eq(:rock)
    end
  end

  describe "#beats?" do
    it "rock beats scissors" do
      rock = Game::Throw.new(:rock)
      scissors = Game::Throw.new(:scissors)
      expect(rock.beats?(scissors)).to be true
    end

    it "scissors beats paper" do
      scissors = Game::Throw.new(:scissors)
      paper = Game::Throw.new(:paper)
      expect(scissors.beats?(paper)).to be true
    end

    it "paper beats rock" do
      paper = Game::Throw.new(:paper)
      rock = Game::Throw.new(:rock)
      expect(paper.beats?(rock)).to be true
    end

    it "rock does not beat paper" do
      rock = Game::Throw.new(:rock)
      paper = Game::Throw.new(:paper)
      expect(rock.beats?(paper)).to be false
    end
  end
end

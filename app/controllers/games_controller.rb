# frozen_string_literal: true

class GamesController < ApplicationController
  def index
    @throws = Game::Rules.throws
  end

  def play
    player_throw = validate_throw_param!
    return unless player_throw

    opponent_result = Api::ThrowClient.fetch

    @result = Game::Resolver.new(
      player_throw: player_throw,
      opponent_throw: opponent_result.throw_name
    )
    @used_fallback = opponent_result.fallback?

    respond_to do |format|
      format.html { render :result }
      format.turbo_stream { render :result }
    end
  end

  private

  def validate_throw_param!
    throw_param = params[:throw]&.downcase

    unless throw_param.present? && Game::Rules.valid_throw?(throw_param)
      redirect_to root_path, alert: "Invalid throw selection"
      return nil
    end

    throw_param.to_sym
  end
end

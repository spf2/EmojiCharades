class TurnController < ApplicationController

  def create
    turn = Turn.new(params[:turn].merge(:game_id=>params[:game_id]))
    turn.save!
    render :xml => turn
  end

  def update
    turn = Turn.find(params[:id])
    # TODO(spf): ensure that updater is game owner
    turn.result = params[:turn][:result]
    turn.save!
    render :xml => turn
  end
end

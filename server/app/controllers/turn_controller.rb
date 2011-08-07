class TurnController < ApplicationController

  def index
    turns = Turn.find_by_game_id(params[:game_id])
    render :json => turns
  end

  def show
    turn = Turn.find(params[:id])
    render :json => turn
  end
  
  def create
    turn = Turn.new(params[:turn])
    turn.save!
    render :json => turn
  end

  def update
    turn = Turn.find(params[:id])
    # TODO(spf): ensure that updater is game owner
    turn.result = params[:turn][:result]
    turn.save!
    render :json => turn
  end
end

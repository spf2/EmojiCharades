class GameController < ApplicationController
  def index
    games = Game.all
    render :json => games.to_json(:include => :owner)
  end

  def create
    game = Game.new(params[:game])
    game.save!
    render :json => game
  end

  def show
    game = Game.find(params[:id])
    render :json => game
  end
end

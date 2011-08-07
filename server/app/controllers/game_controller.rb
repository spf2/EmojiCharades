class GameController < ApplicationController
  def index
    games = Game.all(:include => :owner)
    render :json => games.to_json(:include => :owner)
  end

  def create
    game = Game.new(params[:game])
    game.save!
    render :json => game
  end

  def show
    game = Game.find(params[:id], :include => [:owner, :turns])
    render :json => game.to_json(:include => [:owner, :turns])
  end
end

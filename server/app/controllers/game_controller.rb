class GameController < ApplicationController
  # TODO(spf): eager loading of dependent objects

  def index
    games = Game.all
    render :json => games.to_json
      #(:include => {
      #                            :owner => {},
      #                            :turns => { :include => :user }
      #                          })
  end

  def create
    game = Game.new(params[:game])
    game.save!
    render :json => game
  end

  def show
    game = Game.find(params[:id])
    render :json => game.to_json
  end
end

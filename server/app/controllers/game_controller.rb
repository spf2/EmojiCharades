class GameController < ApplicationController
  # TODO(spf): eager loading of dependent objects

  def index
    games = Game.all
    render :xml => games.to_xml(:include => {
                                  :owner => {},
                                  :turns => { :include => :user }
                                })
  end

  def create
    game = Game.new(params[:game])
    game.save!
    render :xml => game
  end

  def show
    game = Game.find(params[:id])
    render :xml => game.to_xml
  end
end

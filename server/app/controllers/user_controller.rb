class UserController < ApplicationController
  def index
    render :xml => User.all
  end

  def show
    render :xml => User.find(params[:id])
  end

  def create
    user = User.new(params[:user])
    user.save!
    render :xml => user
  end
end

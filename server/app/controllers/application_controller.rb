class ApplicationController < ActionController::Base
  protect_from_forgery

  def render_error(status, message)
    render :status => status, :text => message
  end
end

require 'test_helper'

class TurnControllerTest < ActionController::TestCase
  test "can add turns to a game" do
    post :create, :turn => { :game_id => games(:game1).id,
      :user_id => users(:user1).id, :guess => "elephant" }
      
  end
end

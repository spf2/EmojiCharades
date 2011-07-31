require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "can create and get game" do
    game = Game.new(:owner=>users(:user1), 
                    :hint=>"foo")
    assert game.save
    assert Game.find(game)
  end

  test "can find done games" do
    assert 2 == Game.where(:done_at=>nil).size
    game = games(:game1)
    game.done_at = Time.now
    assert game.save, "save failed"
    assert 1 == Game.where(:done_at=>nil).size, "done not persisted"
  end
end

require 'test_helper'

class TurnTest < ActiveSupport::TestCase
  test "should not add turns to own game" do
    turn = Turn.new(:game=>games(:game1), 
                    :user=>users(:user1), 
                    :guess=>"elephant")
    assert !turn.save, "saved a turn to own game"
  end

  test "should not set result in turn" do
    turn = Turn.new(:game=>games(:game1), 
                    :user=>users(:user2), 
                    :guess=>"elephant",
                    :result=>RESULT[:right])
    assert !turn.save, "save a turn with result"
  end

  test "turns transition game state" do
    game = Game.new(:owner=>users(:user1), :hint=>"some hint")
    assert game.save, "game not ok"
    assert !Game.find(game).done_at, "game should not be done"

    turn1 = Turn.new(:user=>users(:user2), :game=>game, :guess=>"bad guess")
    assert turn1.save
    turn1.result = RESULT[:wrong]
    assert turn1.save
    assert !Game.find(game).done_at, "game should not be done"

    turn2 = Turn.new(:user=>users(:user2), :game=>game, :guess=>"good guess")
    assert turn2.save
    turn2.result = RESULT[:right]
    assert turn2.save
    assert Game.find(game).done_at, "game should be done"

    turn2 = Turn.new(:user=>users(:user2), :game=>game, :guess=>"late guess")
    assert !turn2.save, "cannot add turn to done game"
  end
end

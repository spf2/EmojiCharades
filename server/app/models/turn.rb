class Turn < ActiveRecord::Base
  after_validation :maybe_update_game
  before_create :result_not_specified
  belongs_to :game, :touch => true
  belongs_to :user
  validate :creator_is_not_game_owner
  validate :game_is_not_done
  validates_presence_of :game
  validates_presence_of :user
  validates_length_of(:guess,
                      :maximum => 255,
                      :message => "1-255 characters")

  def result_not_specified
    result.nil?
  end

  def creator_is_not_game_owner
    errors.add(:default, "cannot guess at your own game") if
      user_id == game.owner_id
  end

  def game_is_not_done
    errors.add(:default, "cannot modify done game") if game.done_at
  end

  def maybe_update_game
    if result == RESULT[:right]
      game.done_at = Time.now
      game.save!
    end
  end
end

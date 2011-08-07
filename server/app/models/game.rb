class Game < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_many :turns
  validates_presence_of :owner_id
  validates_length_of(:hint,
                      :within => 1..255,
                      :too_short => "cannot be missing",
                      :too_long => "at most 255 characters")
end

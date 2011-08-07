class Game < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_many :turns
  validates_presence_of :owner
  validates_length_of(:hint,
                      :within => 1..255,
                      :too_short => "at least 1 character",
                      :too_long => "at most 255 characters")
end

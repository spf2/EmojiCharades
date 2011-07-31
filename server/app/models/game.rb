class Game < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  has_many :turns
  validates_presence_of :owner
  validates_length_of(:hint,
                      :maximum => 255,
                      :message => "1-255 characters")
end

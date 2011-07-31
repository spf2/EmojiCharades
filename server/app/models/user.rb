class User < ActiveRecord::Base
  has_many :games
  validates_format_of(:name,
                      :with => /^\w+$/,
                      :message => "letters and numbers only")
  validates_length_of(:name,
                      :maximum => 15,
                      :message => "1-15 characters")
  validates_uniqueness_of :name
end

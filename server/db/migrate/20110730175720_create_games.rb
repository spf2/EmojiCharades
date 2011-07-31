class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.integer :owner_id
      t.string :hint
      t.timestamp :done_at

      t.timestamps
    end
  end

  def self.down
    drop_table :games
  end
end

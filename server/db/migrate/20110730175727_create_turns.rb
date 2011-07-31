class CreateTurns < ActiveRecord::Migration
  def self.up
    create_table :turns do |t|
      t.integer :user_id
      t.integer :game_id
      t.string :guess
      t.integer :result

      t.timestamps
    end
  end

  def self.down
    drop_table :turns
  end
end

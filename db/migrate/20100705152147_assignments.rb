class Assignments < ActiveRecord::Migration

  def self.up
    create_table :assignments do |t|
      t.integer :user_id
      t.integer :role_id
    end
  end

  def self.down
    drop_table :assignments
  end

end


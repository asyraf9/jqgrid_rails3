class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.text :description
      t.integer :staff_no

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

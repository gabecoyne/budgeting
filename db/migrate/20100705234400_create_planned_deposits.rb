class CreatePlannedDeposits < ActiveRecord::Migration
  def self.up
    create_table :planned_deposits do |t|
      t.integer :account_id
      t.integer :bucket_id
      t.string :name
      t.float :amount
      t.date :next
      t.integer :repeat
      t.string :repeat_type

      t.timestamps
    end
  end

  def self.down
    drop_table :planned_deposits
  end
end

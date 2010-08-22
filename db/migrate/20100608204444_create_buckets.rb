class CreateBuckets < ActiveRecord::Migration
  def self.up
    create_table :buckets do |t|
      t.integer :account_id
      t.string :name
      t.float :balance, :default => 0, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :buckets
  end
end

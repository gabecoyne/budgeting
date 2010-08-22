class CreatePlannedBuckets < ActiveRecord::Migration
  def self.up
    create_table :planned_buckets do |t|
      t.integer :planned_deposit_id
      t.integer :bucket_id
      t.float :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :planned_buckets
  end
end

class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :bucket_id
      t.datetime :date
      t.string :label
      t.string :notes
      t.string :status
      t.float :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end

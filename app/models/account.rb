class Account < ActiveRecord::Base
  has_many :buckets
  has_many :planned_deposits
  belongs_to :user
  def bucket(id)
    self.buckets.first(id)
  end
  def no_bucket
    self.buckets.where('name = ?', "NO BUCKET").first
  end
  def transactions
    Transaction.where("bucket_id in (?)",self.buckets)
  end
end

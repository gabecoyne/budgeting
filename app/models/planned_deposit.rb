class PlannedDeposit < ActiveRecord::Base
  has_many :planned_buckets
  belongs_to :budget
  belongs_to :account
end

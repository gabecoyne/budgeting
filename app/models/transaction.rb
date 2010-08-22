class Transaction < ActiveRecord::Base
  belongs_to :bucket
  default_scope order("date desc")
end

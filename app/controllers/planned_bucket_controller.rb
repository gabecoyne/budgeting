class PlannedBucketController < ApplicationController
  before_filter :validate_account, :get_months
end

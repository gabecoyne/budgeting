class PlanController < ApplicationController
  before_filter :validate_account, :get_months
  def index
    
  end
end

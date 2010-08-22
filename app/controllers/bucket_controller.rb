class BucketController < ApplicationController
  before_filter :validate_account, :get_months
  def create
    Bucket.create(params[:bucket])
    flash[:message] = "New Bucket (#{params[:bucket][:name]}) created."
    redirect_to :controller => (params[:redirect_controller] ? params[:redirect_controller] : "transaction"), :action => "index"
  end
  def destroy
    bucket = Bucket.find(params[:id])
    if bucket.name == "NO BUCKET"
      flash[:message] = "You must keep NO BUCKET."
      redirect_to :controller => "transaction", :action => "index"
      return false
    end
    account = bucket.account
    if account.buckets.length == 1
      flash[:message] = "You must have at least one bucket."
      redirect_to :controller => "transaction", :action => "index"
      return false
    end
    bucket.transactions.update_all("bucket_id=#{account.no_bucket.id}")
    bucket.destroy()
    redirect_to :controller => "transaction", :action => "index"
  end
end

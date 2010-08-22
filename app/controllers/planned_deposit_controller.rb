class PlannedDepositController < ApplicationController
  def index
  end
  def create
    PlannedDeposit.create(params[:planned_deposit])
    flash[:message] = "New Scheduled Deposit Created"
    redirect_to :controller => "plan", :action => "index"
  end
  def destroy
    PlannedDeposit.destroy(params[:id])
    flash[:message] = "Scheduled Deposit Deleted"
    redirect_to :controller => "plan", :action => "index"
  end
end

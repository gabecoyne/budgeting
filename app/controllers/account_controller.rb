class AccountController < ApplicationController
  def index
    @accounts = @user.accounts.order("active desc, name asc")
  end
  def activate
    @user.accounts.update_all("active=0")
    params[:accounts].each_pair do |id,account|
      Account.update(id,account)
    end
    flash[:message] = "Account activation saved."
    redirect_to :action => "index"
  end
end

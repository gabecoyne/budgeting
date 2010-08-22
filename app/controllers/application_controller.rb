class ApplicationController < ActionController::Base
  before_filter :set_user

private
  def set_user
    if @user.nil? && session[:id]
      @user = User.find(session[:id])
    end
    if @user.nil?
      access_denied
    else
      # get_months
      # validate_account
    end
  end

  def access_denied
    session[:return_to] = request.request_uri
    flash[:error] = 'Oops. <br />You need to login before you can view that page.'.html_safe unless request.request_uri == "/"
    redirect_to :controller => 'user', :action => 'login'
  end
  
  def get_months
    @months = Transaction.find_by_sql([
      "select distinct year(date) as year, month(date) as month
      from transactions
      where bucket_id in (select id from buckets where account_id=?)
      order by date desc",
      params[:account_id]
    ])
  end
  
  def validate_account
    # Make sure user owns current account, otherwise redirect out to their first account
    begin
      @account = @user.accounts.find(params[:account_id]) if !params[:account_id].nil?
    rescue ActiveRecord::RecordNotFound
      flash[:message] = "You do not have access to that account. Here is one of your accounts."
      redirect_to transaction_month_path(
        :account_id => @user.accounts.first.id, 
        :year => params[:year] || Time.now.strftime("%Y"), 
        :month => params[:month] || Time.now.strftime("%m")
      )
      return
    end
  end
  
end

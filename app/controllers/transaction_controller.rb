class TransactionController < ApplicationController
  layout "application"
  before_filter :validate_account, :get_months
  def create
    params[:transaction][:date] = Time.now
    @account.bucket(params[:id]).transactions.create(params[:transaction])
    redirect_to :controller => "transaction", :action => "index"
  end
  def index    
    if !params[:account_id]
      redirect_to transaction_month_path(
        :account_id => @user.accounts.first.id, :year => Time.now.strftime("%Y"), :month => Time.now.strftime("%m")
      )
      return false
    end
    params[:year] = Time.now.strftime("%Y") unless params[:year]
    params[:month] = Time.now.strftime("%m") unless params[:month]
    @month = Transaction.where("bucket_id in (select id from buckets where account_id=?)",params[:account_id]).where("year(date)=?",params[:year]).where("month(date)=?",params[:month]).order("date desc")
    @no_bucket = @month.where("bucket_id=#{@account.buckets.find_by_name('NO BUCKET').id}")
    @pending = @month.where("status='pending'")
    @cleared = @month.where("status='cleared'")
    @month_total = 0
    @month_income_total = 0
    @month_expense_total = 0
    @cleared_total = 0
    @pending_total = 0
    @no_bucket_total = 0
    @month.each do |trans|
      @month_total += trans.amount
      @cleared_total += trans.amount if trans.status == "cleared"
      @pending_total += trans.amount if trans.status == "pending"
      @no_bucket_total += trans.amount if trans.bucket.name == "NO BUCKET"
      if 0 < trans.amount
        @month_income_total += trans.amount
      else
        @month_expense_total += trans.amount
      end
    end
    @available_balance = @month_total
    @account.buckets.each do |bucket|
      @available_balance -= bucket.balance unless bucket.balance < 0 # don't add in negative balances...
    end
    
    @bucket_total = 0
    @account.buckets.each do |bucket|
      @bucket_total += bucket.balance
    end
  end
end

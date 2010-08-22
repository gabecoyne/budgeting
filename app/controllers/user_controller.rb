class UserController < ApplicationController
  skip_before_filter :set_user
  layout "login"
  def login
    @user = User.new
    @user.username = params[:username]
  end

  def process_login
    if @user = User.authenticate(params[:user])
      session[:id] = @user.id # Remember the user's id during this session 
      flash[:message] = import_mint # import new transactions on login
      redirect_to transaction_month_path(
        :account_id => @user.accounts.first.id, 
        :year => params[:year] || Time.now.strftime("%Y"), 
        :month => params[:month] || Time.now.strftime("%m")
      )
    else
      flash[:error] = 'Invalid login.' 
      redirect_to :action => 'login', :username => params[:user][:username]
    end
  end

  def logout
    reset_session
    flash[:message] = 'Logged out.' 
    redirect_to :action => 'login' 
  end
  
  def import
    set_user
    flash[:message] = import_mint
    redirect_to transaction_month_path(
      :account_id => params[:account_id], :year => Time.now.strftime("%Y"), :month => Time.now.strftime("%m")
    )
  end
  
private
  def import_mint
    flash[:message] = ""
    # cache results for 1 hour
    cachefile = File.join(Rails.root,"tmp","cache","mint_cache_#{@user.id}.csv")
    cache_age = ((Time.now - File.open(cachefile,"r").mtime) / 60).to_i if File.exist?(cachefile)
    # flash[:message] << "Cache ctime: #{cache_age.strftime("%m/%d/%Y %I:%M%p")}"
    # flash[:message] << "Now: #{Time.now.strftime("%m/%d/%Y %I:%M%p")}"
    # flash[:message] << "Cache Age: #{cache_age.to_i} (minutes)"
    # Check cached mint file  ##########################################
    if File.exist?(cachefile) && cache_age < 60
      flash[:message] << "Didn't import from Mint.com... Last import was less than an hour ago (#{cache_age} minutes ago)"
      return flash[:message]
      # csv = File.read(cachefile)
    else  
      # Get new mint transactions ##########################################
      c = Curl::Easy.new
      c.enable_cookies = true
      c.cookiejar = "cookie.txt"
      c.follow_location = true

      # Log in ##########################################
      # flash[:message] << "Logging into Mint..."
      c.url = "https://wwws.mint.com/loginUserSubmit.xevent"
      c.http_post(
        Curl::PostField.content('username', @user.mint_username),
        Curl::PostField.content('password', @user.mint_password),
        Curl::PostField.content('task', 'L')
      )
      # Get transactions csv data ##########################################
      # flash[:message] << "Downloading Transactions..."
      c.url = "https://wwws.mint.com/transactionDownload.event?"
      c.perform
  
      # Remove Cached Content from new file  ##########################################
      # Not while it's in seed because the db gets truncated each time
      if File.exist?(cachefile)
        flash[:message] << "Using CACHED + NEW mint transactions<br />"
        # Open old file - go through each line and replace it out of new file
        csv = c.body_str
        File.open(cachefile).each { |line|
          puts "Removing dup line: #{line}"
          csv = csv.sub(line,"")
        }
      else
        csv = c.body_str
      end
  
      # save cached file ##########################################
      f = File.open(cachefile, "w")
      f.puts c.body_str
      f.close
    end

    # remove csv header
    csv = csv.sub('"Date","Description","Original Description","Amount","Transaction Type","Category","Account Name","Labels","Notes"
',"")
    if csv.index("<html")
      flash[:message] = "Mint import error"
      redirect_to "/"
      return false
    end
    
    lines = csv.split("\n")    
    flash[:message] << "Imported #{lines.length} transactions from Mint.com<br />"
    lines.each do |line|
      f = line.gsub('"','').split(",")
      # flash[:message] << line
      # Set transaction amount ##########################################
      if f[4] == "debit"
        amount = 0-f[3].to_f
      else
        amount = f[3].to_f
      end
      # Find or create account ##########################################
      # flash[:message] << "Looking for Account #{f[6]}"
      account = @user.accounts.find_by_name(f[6])
      if account.nil?
        flash[:message] << "Create Account #{f[6]}<br />"
        account = @user.accounts.create({ :name => f[6], :active => true})
        account.buckets.create({ :name => "NO BUCKET", :balance => 0 })
      end
      # Find or create bucket ##########################################
      # flash[:message] << "Looking for Bucket #{f[5]}"
      f[5] = "NO BUCKET"
      bucket = account.buckets.find_by_name(f[5])
      if bucket.nil?
        flash[:message] << "Create Bucket #{f[5]}<br />"
        bucket = account.buckets.create({ :name => f[5], :balance => 0})
      end
      Transaction.create({ :date => Date.parse(f[0]), :label => f[2], :amount => amount, :bucket_id => bucket.id, :status => "cleared" })
    end # end lines.each
    flash[:message]
  end # end import_mint
end

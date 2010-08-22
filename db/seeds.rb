# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

@user = User.create({
  :username => "gabecoyne", :password => "cLu54ebr", :mint_username => "gabe@coyne-design.com", :mint_password => "cLu54ebr"
})

# cache results for 1 hour
cachefile = File.join(Rails.root,"tmp","cache","mint_cache_#{@user.id}.csv")
cache_age = File.open(cachefile,"r").ctime - Time.now unless !File.exist?(cachefile)
if File.exist?(cachefile) && cache_age.minutes < 60
  puts "Using CACHED mint transactions"
  csv = File.read(cachefile)
else  
  c = Curl::Easy.new
  c.enable_cookies = true
  c.cookiejar = "cookie.txt"
  c.follow_location = true

  # Log in ##########################################
  puts "Logging into Mint..."
  c.url = "https://wwws.mint.com/loginUserSubmit.xevent"
  c.http_post(
    Curl::PostField.content('username', @user.mint_username),
    Curl::PostField.content('password', @user.mint_password),
    Curl::PostField.content('task', 'L')
  )
  # Get transactions csv data ##########################################
  puts "Downloading Transactions..."
  c.url = "https://wwws.mint.com/transactionDownload.event?"
  c.perform
  
  # Remove Cached Content from new file  ##########################################
  # Not while it's in seed because the db gets truncated each time
  if File.exist?(cachefile)
    puts "Using CACHED + NEW mint transactions"
    # Open old file - go through each line and replace it out of new file
    csv = c.body_str
    # File.open(cachefile).each { |line|
    #   puts "Removing dup line: #{line}"
    #   csv = csv.sub(line,"")
    # }
    # csv = c.body_str.sub(File.read(cachefile),"") # remove all previous transactions
  else
    csv = c.body_str
  end
  puts csv
  
  # save cached file with latest mint data ##########################################
  f = File.open(cachefile, "w")
  f.puts c.body_str
  f.close
end

csv = csv.sub('"Date","Description","Original Description","Amount","Transaction Type","Category","Account Name","Labels","Notes"
',"")
if csv.index("<html")
  puts "Mint import error"
  return false
end

lines = csv.split("\n")
puts "Importing #{lines.length} transactions from Mint.com"
# lines.delete_at(0) if !lines.nil? && lines[0].index("Transaction Type") # Delete header line
lines.each do |line|
  f = line.gsub('"','').split(",")
  puts line
  # Set transaction amount ##########################################
  if f[4] == "debit"
    amount = 0-f[3].to_f
  else
    amount = f[3].to_f
  end
  # Find or create account ##########################################
  # puts "Looking for Account #{f[6]}"
  account = @user.accounts.find_by_name(f[6])
  if account.nil?
    puts "Create Account #{f[6]}"
    account = @user.accounts.create({ :name => f[6], :active => true})
    account.buckets.create({ :name => "NO BUCKET", :balance => 0 })
  end
  # Find or create bucket ##########################################
  # puts "Looking for Bucket #{f[5]}"
  f[5] = "NO BUCKET"
  bucket = account.buckets.find_by_name(f[5])
  if bucket.nil?
    puts "Create Bucket #{f[5]}"
    bucket = account.buckets.create({ :name => f[5], :balance => 0})
  end
  Transaction.create({ :date => Date.parse(f[0]), :label => f[2], :amount => amount, :bucket_id => bucket.id, :status => "cleared" })
end

##############################################################################################################################

# accounts = []
# 5.times do
#   accounts << user.accounts.create({:name => Faker::Lorem.words.join(" ") })
# end
# 
# buckets = []
# accounts.each do |acct|
#   10.times do
#     buckets << acct.buckets.create({:name => Faker::Lorem.words.join(" "), :balance => rand(1000) })
#   end
# end
# 
# buckets.each do |bucket|
#   200.times do
#     bucket.transactions.create({ 
#       :date => DateTime.now - rand(100).days, 
#       :label => Faker::Lorem.words.join(" ") , 
#       :notes => Faker::Lorem.words.join(" "),
#       :amount => 1000-rand(2000)
#     })
#   end
# end
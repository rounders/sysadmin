##
# Backup
# Generated Template
#
# For more information:
#
# View the Git repository at https://github.com/meskyanichi/backup
# View the Wiki/Documentation at https://github.com/meskyanichi/backup/wiki
# View the issue log at https://github.com/meskyanichi/backup/issues
#
# When you're finished configuring this configuration file,
# you can run it from the command line by issuing the following command:
# 
# $backup perform --trigger databases
#
# will backup all databases in the local mysql database except for the 'mysql' & 'information_schema' databases
# will find all apps installed in AppsPath and sync their shared/system folders to s3
#

require 'mysql2'

# --- configuration ---
DBUser     = 'root'
DBPass     = 'xxxxx'
S3Key      = 'xxxxxxx'
S3Secret   = 'xxxxxxx'
S3Bucket   = 'mybucket'
S3Path     = '/servername'
NotifyTo   = 'to@gmail.com'
NotifyFrom = 'from@gmail.com'              

# Also, dont forget to configure Mail info below

client = Mysql2::Client.new(:host => "localhost", :username => DBUser, :password => DBPass)
databases = client.query("SHOW DATABASES").collect {|row| row['Database']}
databases.delete_if {|db| ['mysql','information_schema'].include? db}

Backup::Configuration::Database::MySQL.defaults do |db|
  db.username           = DBUser
  db.password           = BDPass
  db.host               = "localhost"
  db.port               = 3306
  db.socket             = "/var/run/mysqld/mysqld.sock"
end


Backup::Model.new(:databases, 'My Backup') do
  notify_by Mail do |mail|
    mail.on_success           = true
    mail.on_failure           = true

    mail.from                 = NotifyFrom
    mail.to                   = NotifyTo
    mail.address              = 'smtp.gmail.com'
    mail.port                 = 587
    mail.domain               = 'mydomain.com'
    mail.user_name            = 'user@gmail.com'
    mail.password             = 'password'
    mail.authentication       = 'plain'
    mail.enable_starttls_auto = true
  end
  
  databases.each do |name|
    database MySQL do |db|
      db.name               = name
    end
  end

  ##
  # Amazon Simple Storage Service [Storage]
  #
  # Available Regions:
  #
  #  - ap-northeast-1
  #  - ap-southeast-1
  #  - eu-west-1
  #  - us-east-1
  #  - us-west-1
  #
  store_with S3 do |s3|
    s3.access_key_id      = S3Key
    s3.secret_access_key  = S3Secret
    s3.region             = 'us-east-1'
    s3.bucket             = S3Bucket
    s3.path               = S3Path
    s3.keep               = 10
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip do |compression|
    compression.best = true
    compression.fast = false
  end

end


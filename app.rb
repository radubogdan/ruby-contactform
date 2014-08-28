require 'sinatra'
require 'json'
require 'redis'
require 'uuid'

r = Redis.new
r.select 1

helpers do
  def valid_email?(email)
    regex = /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
    email =~ regex ? true : false
  end
end

post '/user/register' do
  email = params[:email]
  not_exist = r.sadd "emailset", email

  if email && valid_email?(email) && not_exist
    uuid = SecureRandom.uuid
    r.hset "emails", uuid, email
    "Your token for #{email} is #{uuid}"
  else
    "Email already exist or invalid email was given"
  end
end

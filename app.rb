require 'sinatra'
require 'json'
require 'redis'
require 'uuid'
require 'mandrill'

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

  if !not_exist
    "Email already registered, 403"
  elsif email && valid_email?(email)
    uuid = SecureRandom.uuid
    r.hset "emails", uuid, email
    "Your token for #{email} is #{uuid}"
  else
    "Invalid Email address"
  end
end

post '/user/:token' do
  # --data is email, name, message
  user_email = (r.hmget "emails", params[:token]).join

  if !user_email
    "User not found: 406"
  else
    mandrill_api_key = ENV["MANDRILL_APIKEY"]
    m = Mandrill::API.new(mandrill_api_key)

    message = {
      :to => [{ :email => user_email }],
      :from_email => params[:email],
      :subject => params[:subject],
      :from_name => "Message from #{params[:name]}",
      :text => params[:message]
    }

    sending = m.messages.send message
    sending[0]["status"] == 'sent' ? "Message sent" : "Reject reason: #{sending[0]["reject_reason"]}"
  end
end

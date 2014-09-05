require 'sinatra'
require 'json'
require 'redis'
require 'uuid'
require 'mandrill'

# Configure Redis and Mandrill
redis_uri = URI.parse(ENV["REDISTOGO_URL"])
mandrill_api_key = ENV["MANDRILL_APIKEY"]

r = Redis.new(:host => redis_uri.host, :port => redis_uri.port, :password => redis_uri.password)
m = Mandrill::API.new(mandrill_api_key)

# Helper methods
helpers do
  def valid_email?(email)
    regex = /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
    email =~ regex ? true : false
  end
end

# Endpoint: /user/register
# Params: email
# Example: curl --data "email=dotix@debian.org.ro" 127.0.0.1:9292/user/register
# Return: token for email
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

# Endpoint: /user/:token
# Params: email, subject, name, message
# Example:  curl --data "email=example@gmail.com&name=Example&message=Salut&subject=Hello Dotix" 127.0.0.1:9292/user/3x4mp13-0000-0000
# Return: status
post '/user/:token' do
  # --data is email, name, message
  user_email = (r.hmget "emails", params[:token]).join

  if !user_email
    "User not found: 406"
  else
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

require 'sinatra'
require 'sinatra/cross_origin'
require 'redis'
require 'uuid'
require 'mandrill'
require 'json'

configure do
  enable :cross_origin
end

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

# Redirect to gh-pages
get '/' do
  redirect "http://radubogdan.github.io/ruby-contactform/"
end

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
    {status => 406, message => 'Email not found'}.to_json
  else
    message = {
      :to => [{ :email => user_email }],
      :from_email => params[:email],
      :subject => params[:subject],
      :from_name => params[:name],
      :text => params[:message]
    }

    sending = m.messages.send message
    
    if sending[0]["status"] == 'sent'
      {"status" => status, "message" => "Message sent"}.to_json
    else
      {"status" => 400, "message" => "#{sending[0]["reject_reason"]}"}.to_json
    end
  end
end

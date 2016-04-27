require 'sinatra'
require 'redis'
require 'uuid'
require 'sendgrid-ruby'

API_KEY = ENV['SENDGRID_API_KEY']
REDIS_URL = URI.parse(ENV["REDISTOGO_URL"])

sendgrid_client = SendGrid::Client.new(api_key: API_KEY)

redis_client = Redis.new(
  host: REDIS_URL.host,
  port: REDIS_URL.port,
  password: REDIS_URL.password
)

# Redirect to gh-pages
get '/' do
  redirect "http://radubogdan.github.io/ruby-contactform/"
end

# Params:
#   email
# Returns:
#   status => code,
#   message => error description or TOKEN
# Example:
#   curl --data "email=croitoruradubogdan@gmail.com" localhost:4567/user/register
#   { "status": 200, "message": "c0dff7ce-9651-44f1-afa6-5172515b1e74" }
post '/user/register' do
  email = params[:email]
  status = redis_client.sadd "emailset", email # true / false

  if email && status
    uuid = SecureRandom.uuid
    redis_client.hset "emails", uuid, email
    { status: 200, message: uuid }.to_json
  else
    { status: 403, message: "Email invalid or already registered" }.to_json
  end
end

# Params:
#   email,
#   subject,
#   name,
#   message
# Returns:
#   status => code,
#   message => description
# Example:
#   curl --data "email=example@gmail.com&name=Example&message=Salut&subject=Hello there" localhost:4567/user/3x4mp13-0000-0000
#   { "status": 200, "message": "success" }
post '/user/:token' do
  user_email = (redis_client.hmget "emails", params[:token]).join

  if user_email.empty?
    return { status: 406, message: "User not found. Please register first." }.to_json
  end

  mail = SendGrid::Mail.new do |m|
    m.to = user_email
    m.from_name = params[:name]
    m.from = params[:email]
    m.subject = params[:subject]
    m.text = params[:message]
  end

  res = sendgrid_client.send(mail)

  { status: res.code, message: res.body["message"] }.to_json
end

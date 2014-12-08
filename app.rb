require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
#  Meetup.create(name: 'a new meetup', description: "meet in person", location:"Launch Academy", attendees: "a user", comments: "it was fun")
  @meetups = Meetup.all.order("name")
  erb :index
end

get '/meetups/:id' do
  @id=params[:id]
  @meetup = Meetup.find(@id)
  erb :show
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end

post '/' do
  @name = params['name'].capitalize
  @location = params['location'].capitalize
  @description = params['description'].capitalize
  Meetup.create(name: @name, description: @description, location: @location, attendees: "none", comments: "none" )
  redirect '/'
end

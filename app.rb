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
  @meetups = Meetup.order(name: :asc)
  erb :index
end

get '/meetups/:id' do
  @id=params[:id]
  @meetup = Meetup.find(@id)
  @all_attendees = Attendee.all
  @meetup_attendees = @meetup.users
  @comments = Comment.where(:meetup_id => @id)
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
  authenticate!
  @name = params['name'].capitalize
  @location = params['location'].capitalize
  @description = params['description'].capitalize
  Meetup.create(name: @name, description: @description, location: @location)
  flash[:notice] = "Creating the meetup was a sucess."
  redirect '/'
end

post '/meetups/:id' do
  authenticate!
  @id = params[:id]
  @user = current_user
  begin
  Attendee.create!(user_id: @user.id, meetup_id: @id)
  flash[:notice] = "You just joined the meetup!"
  rescue
  flash[:notice] = "You already joined the meetup!"
  end
  redirect "/meetups/#{@id}"
end

post '/leave/:id' do
  @id=params[:id]
  @user = current_user
  if Attendee.exists?(:user_id => @user.id, :meetup_id => @id)
    Attendee.destroy_all(:user_id => @user.id, :meetup_id => @id)
    flash[:notice] = "You just left the meetup!"
  else
    flash[:notice] = "Your not in the meetup!"
  end
  redirect "/meetups/#{@id}"
end

post '/comments/:id' do
  authenticate!
  @comment = params[:comment]
  @meetup_id = params[:id]
  @user = current_user
  @user_id = @user.id
  Comment.create(:user_id => @user_id, :meetup_id => @meetup_id, :comment => @comment)
  redirect "/meetups/#{@meetup_id}"
end


#notes
#class Movie < AR::Base
# belongs_to :genre
#end

# .where - returns 0 or more records in an array
# .find_by(...) - returns 0 or 1 record (or nil)

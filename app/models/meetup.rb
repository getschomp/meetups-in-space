class Meetup < ActiveRecord::Base
  # has_many :attendees, dependent: :destroy
  # has_many :users, :through => :atendees
end

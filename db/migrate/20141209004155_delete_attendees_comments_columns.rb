class DeleteAttendeesCommentsColumns  < ActiveRecord::Migration
  def up
    remove_column :meetups, :comments
    remove_column :meetups, :attendees
  end

  def down
    add_column :meetups, :comments, :string
    add_column :meetups, :attendees,  :string
  end
end

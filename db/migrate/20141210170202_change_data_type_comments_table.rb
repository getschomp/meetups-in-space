class ChangeDataTypeCommentsTable < ActiveRecord::Migration
  def up
    remove_column :comments, :user_id
    remove_column :comments, :meetup_id
  end

  def down
    add_column :comments, :user_id, :string
    add_column :comments, :meetup_id,  :string
  end
end

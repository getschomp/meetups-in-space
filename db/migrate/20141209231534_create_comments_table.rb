class CreateCommentsTable < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :user_id, null: false
      t.string :meetup_id, null: false
      t.string :comment, null: false

      t.timestamps
    end
  end
end

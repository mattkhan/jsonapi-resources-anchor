class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :description, null: false
      t.references :user, null: false
      t.timestamps
    end
  end
end

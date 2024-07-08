class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.string :text, null: false
      t.references :commentable, polymorphic: true
      t.references :user, null: false
      t.references :deleted_by, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end

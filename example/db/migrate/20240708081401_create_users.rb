class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.integer :integer
      t.decimal :decimal
      t.timestamps
    end
  end
end

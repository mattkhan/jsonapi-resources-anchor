class AddLoljkToExhaustives < ActiveRecord::Migration[7.1]
  def change
    add_column :exhaustives, :loljk, :string
  end
end

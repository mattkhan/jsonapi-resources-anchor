class AddWithDefaultToExhaustives < ActiveRecord::Migration[8.0]
  def change
    add_column :exhaustives, :defaulted_boolean, :boolean, default: false
  end
end

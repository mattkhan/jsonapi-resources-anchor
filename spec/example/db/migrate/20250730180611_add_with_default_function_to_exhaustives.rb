class AddWithDefaultFunctionToExhaustives < ActiveRecord::Migration[8.0]
  def change
    add_column :exhaustives, :defaulted_at, :datetime, default: -> { "NOW()" }
  end
end

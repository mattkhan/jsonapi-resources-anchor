class AddOverridesToExhaustives < ActiveRecord::Migration[7.1]
  def change
    add_column :exhaustives, :model_overridden, :string
    add_column :exhaustives, :resource_overridden, :string
  end
end

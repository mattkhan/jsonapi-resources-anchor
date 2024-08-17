class CreateExhaustives < ActiveRecord::Migration[7.1]
  def change
    create_enum :exhaustive_enum, ["sample", "enum", "value"]

    create_table :exhaustives do |t|
      t.string :string, null: false
      t.string :maybe_string, null: true
      t.text :text, null: false
      t.integer :integer, null: false
      t.float :float, null: false
      t.decimal :decimal, null: false
      t.datetime :datetime, null: false
      t.timestamp :timestamp, null: false
      t.time :time, null: false
      t.date :date, null: false
      t.boolean :boolean, null: false

      # Postgres types
      # https://guides.rubyonrails.org/active_record_postgresql.html#datatypes
      t.binary :binary, null: true
      t.string :array_string, array: true, null: false
      t.string :maybe_array_string, array: true, null: true
      t.json :json, null: false
      t.jsonb :jsonb, null: false
      t.daterange :daterange, null: false
      t.enum :enum, enum_type: :exhaustive_enum, default: "sample", null: false
      t.uuid :uuid, null: false
      t.virtual :virtual_upcased_string, type: :string, as: 'upper(string)', stored: true

      t.timestamps
    end
  end
end

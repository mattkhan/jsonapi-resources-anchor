# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_07_20_203832) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "exhaustive_enum", ["sample", "enum", "value"]

  create_table "comments", force: :cascade do |t|
    t.string "text", null: false
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.bigint "user_id", null: false
    t.bigint "deleted_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["deleted_by_id"], name: "index_comments_on_deleted_by_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "exhaustives", force: :cascade do |t|
    t.string "string", null: false
    t.string "maybe_string"
    t.text "text", null: false
    t.integer "integer", null: false
    t.float "float", null: false
    t.decimal "decimal", null: false
    t.datetime "datetime", null: false
    t.datetime "timestamp", precision: nil, null: false
    t.time "time", null: false
    t.date "date", null: false
    t.boolean "boolean", null: false
    t.binary "binary"
    t.string "array_string", null: false, array: true
    t.string "maybe_array_string", array: true
    t.json "json", null: false
    t.jsonb "jsonb", null: false
    t.daterange "daterange", null: false
    t.enum "enum", default: "sample", null: false, enum_type: "exhaustive_enum"
    t.uuid "uuid", null: false
    t.virtual "virtual_upcased_string", type: :string, as: "upper((string)::text)", stored: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "description", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.integer "integer"
    t.decimal "decimal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
  end

  add_foreign_key "comments", "users", column: "deleted_by_id"
end

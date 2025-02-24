require "rails_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe "Example" do
  def self.snapshot_test(filename, generate)
    it "generates correct #{filename} schema" do
      User.find_or_create_by!(name: "User", role: :admin) # allows ActiveRecord to define instance methods for columns

      schema = generate.call
      path = Rails.root.join("test/files", filename)
      unless File.file?(path)
        File.open(path, "w") { |file| file.write(schema) }
      end

      SnapshotUpdate.prompt(path, schema) if ENV["THOR_MERGE"] && File.read(path) != schema

      expect(File.read(path)).to eql(schema)
    end
  end

  snapshot_test "schema.ts", -> {
    Anchor::TypeScript::SchemaGenerator.call(register: Schema.register, include_all_fields: true)
  }
  snapshot_test "test_schema.ts", -> {
    Anchor::TypeScript::SchemaGenerator.call(register: Schema.register, context: { role: "test" })
  }
  snapshot_test "all_fields_false_schema.ts", -> { Anchor::TypeScript::SchemaGenerator.call(register: Schema.register) }
  snapshot_test "excluded_fields_schema.ts", -> {
    Anchor::TypeScript::SchemaGenerator.call(register: Schema.register, exclude_fields: { User: [:name, :posts] })
  }
  snapshot_test "json_schema.json", -> {
    Anchor::JSONSchema::SchemaGenerator.call(register: Schema.register, include_all_fields: true)
  }
end
# rubocop:enable RSpec/EmptyExampleGroup

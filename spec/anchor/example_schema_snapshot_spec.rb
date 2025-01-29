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

  snapshot_test "schema.ts", -> { Schema.generate(include_all_fields: true) }
  snapshot_test "test_schema.ts", -> { Schema.generate(context: { role: "test" }) }
  snapshot_test "all_fields_false_schema.ts", -> { Schema.generate }
  snapshot_test "excluded_fields_schema.ts", -> { Schema.generate(exclude_fields: { User: [:name, :posts] }) }
  snapshot_test "json_schema.json", -> { Schema.generate(adapter: :json_schema, include_all_fields: true) }
end
# rubocop:enable RSpec/EmptyExampleGroup

require "rails_helper"

RSpec.describe "Example" do
  def self.snapshot_test(filename, generate)
    it "generates correct #{filename} schema" do
      schema = generate.call
      path = Rails.root.join("test/files", filename)
      unless File.file?(path)
        File.open(path, "w") { |file| file.write(schema) }
      end
      expected_schema = File.read(path)

      if ENV["THOR_MERGE"] && expected_schema != schema
        SnapshotUpdate.prompt(path, schema)
        expect(File.read(path)).to eql(schema)
        return
      end

      expect(expected_schema).to eql(schema)
    end
  end

  snapshot_test "schema.ts", -> { Schema.generate(include_all_fields: true) }
  snapshot_test "test_schema.ts", -> { Schema.generate(context: { role: "test" }) }
  snapshot_test "all_fields_false_schema.ts", -> { Schema.generate }
  snapshot_test "json_schema.json", -> { Schema.generate(adapter: :json_schema, include_all_fields: true) }
end

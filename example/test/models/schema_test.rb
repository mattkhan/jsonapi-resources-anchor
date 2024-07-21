require "test_helper"

class SchemaTest < ActiveSupport::TestCase
  class SnapshotUpdate < Thor
    include Thor::Actions

    def self.prompt(...) = new.prompt(...)

    desc "prompt", "Prompt user to update snapshot"
    def prompt(...) = create_file(...)
  end

  def self.snapshot_test(filename, generate)
    test "generates correct #{filename} schema" do
      schema = generate.call
      path = Rails.root.join("test/files", "#{filename}.ts")
      expected_schema = File.read(path)

      if ENV['THOR_MERGE'] && expected_schema != schema
        SnapshotUpdate.prompt(path, schema)
        assert_equal File.read(path), schema
        return
      end

      assert_equal expected_schema, schema
    end
  end

  snapshot_test :schema, -> { Schema.generate }
  snapshot_test :test_schema, -> { Schema.generate(context: { role: 'test' }) }
  snapshot_test :all_fields_false_schema, -> { Schema.generate(include_all_fields: false) }
end

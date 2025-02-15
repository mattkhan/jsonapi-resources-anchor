require "rails_helper"

# rubocop:disable RSpec/EmptyExampleGroup
RSpec.describe "Example" do
  def self.multifile_snapshot_test(filename, generate)
    it "generates correct #{filename} schema" do
      results = generate.call
      results.each do |res|
        filename = res.name

        path = Rails.root.join("test/files/multifile", filename)
        schema = res.text

        unless File.file?(path)
          File.open(path, "w") { |file| file.write(schema) }
        end

        SnapshotUpdate.prompt(path, schema) if ENV["THOR_MERGE"] && File.read(path) != schema
        expect(File.read(path)).to eql(schema)
      end
    end
  end

  multifile_snapshot_test "schema.ts", -> {
    Anchor::TypeScript::MultifileSchemaGenerator.call(
      register: Schema.register,
      context: {},
      include_all_fields: true,
      exclude_fields: nil,
      manually_editable: true,
    )
  }
end
# rubocop:enable RSpec/EmptyExampleGroup

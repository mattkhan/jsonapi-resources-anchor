namespace :anchor do
  desc "Generate JSONAPI::Resource Anchor schema"
  task generate: :environment do
    puts "Generating JSONAPI::Resource Anchor schemas..."

    def write_to(filename, generate)
      path = Rails.root.join("test/files", filename)
      File.open(path, "w") { |f| f.write(generate.call) }
      puts "✅ #{File.basename(path)}"
    end

    def write_to_multi(folder, force, generator)
      folder_path = "test/files/#{folder}"
      Anchor::TypeScript::MultifileSaveService.call(generator:, folder_path:, force:)
      puts "✅ #{folder}"
    end

    write_to "schema.ts", -> {
      Anchor::TypeScript::SchemaGenerator.call(register: Schema.register, include_all_fields: true)
    }
    write_to "test_schema.ts", -> {
      Anchor::TypeScript::SchemaGenerator.call(register: Schema.register, context: { role: "test" })
    }
    write_to "all_fields_false_schema.ts", -> { Anchor::TypeScript::SchemaGenerator.call(register: Schema.register) }
    write_to "excluded_fields_schema.ts", -> {
      Anchor::TypeScript::SchemaGenerator.call(register: Schema.register, exclude_fields: { User: [:name, :posts] })
    }
    write_to_multi "multifile",
      false,
      Anchor::TypeScript::MultifileSchemaGenerator.new(
        register: Schema.register,
        context: {},
        include_all_fields: true,
        exclude_fields: nil,
        manually_editable: true,
      )

    write_to "json_schema.json", -> {
      Anchor::JSONSchema::SchemaGenerator.call(register: Schema.register, include_all_fields: true)
    }
  end

  task multigen: :environment do
    folder_path = "test/files/multifile"
    generator = Anchor::TypeScript::MultifileSchemaGenerator.new(
      register: Schema.register,
      context: {},
      include_all_fields: true,
      exclude_fields: nil,
      manually_editable: true,
    )
    modified_files = Anchor::TypeScript::MultifileSaveService.call(generator:, folder_path:)
    puts modified_files.join(" ")
  end
end

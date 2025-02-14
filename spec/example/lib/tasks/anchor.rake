namespace :anchor do
  desc "Generate JSONAPI::Resource Anchor schema"
  task generate: :environment do
    puts "Generating JSONAPI::Resource Anchor schemas..."

    def write_to(filename, generate)
      path = Rails.root.join("test/files", filename)
      File.open(path, "w") { |f| f.write(generate.call) }
      puts "✅ #{File.basename(path)}"
    end

    def write_to_multi(folder, force, generate)
      FileUtils.mkdir_p("test/files/#{folder}")
      result = generate.call
      result.each do |res|
        path = Rails.root.join("test/files/#{folder}", res[:name])
        if force || !File.exist?(path)
          File.open(path, "w") { |f| f.write(res[:content]) }
          next
        end

        existing_content = File.read(path)
        new_content =
          if existing_content.starts_with?("// START AUTOGEN\n") && existing_content.include?("// END AUTOGEN\n")
            after_end = existing_content.split("// END AUTOGEN\n").second
            [res[:content].split("\n// END AUTOGEN\n").first, "// END AUTOGEN", after_end].join("\n")
          else
            res[:content]
          end

        File.open(path, "w") { |f| f.write(new_content) }
      end
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
    write_to_multi "multifile", false, -> {
      Anchor::TypeScript::MultifileSchemaGenerator.call(
        register: Schema.register,
        context: {},
        include_all_fields: true,
        exclude_fields: nil,
        manually_editable: true,
      )
    }
    write_to "json_schema.json", -> {
      Anchor::JSONSchema::SchemaGenerator.call(register: Schema.register, include_all_fields: true)
    }
  end
end

namespace :anchor do
  desc "Generate JSONAPI::Resource Anchor schema"
  task generate: :environment do
    puts "Generating JSONAPI::Resource Anchor schemas..."

    def write_to(filename, generate)
      path = Rails.root.join('test/files', "#{filename}")
      File.open(path, "w") { |f| f.write(generate.call) }
      puts "✅ #{File.basename(path)}"
    end

    write_to "schema.ts", -> { Schema.generate(include_all_fields: true) }
    write_to "test_schema.ts", -> { Schema.generate(context: { role: 'test' }) }
    write_to "all_fields_false_schema.ts", -> { Schema.generate }
    write_to "json_schema.json", -> { Schema.generate(adapter: :json_schema, include_all_fields: true) }
  end
end

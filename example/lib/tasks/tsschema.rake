namespace :tsschema do
  desc "Generate TypeScript schema"
  task generate: :environment do
    puts "Generating TypeScript schema..."

    def write_to(filename, generate)
      path = Rails.root.join('test/files', "#{filename}.ts")
      File.open(path, "w") { |f| f.write(generate.call) }
      puts "✅ #{File.basename(path)}"
    end

    write_to :schema, -> { Schema.generate }
  end
end

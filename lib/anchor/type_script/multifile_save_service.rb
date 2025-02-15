module Anchor::TypeScript
  class MultifileSaveService
    START_MARKER = "// START AUTOGEN\n"
    END_MARKER = "\n// END AUTOGEN\n"
    REGEX = /#{Regexp.escape(START_MARKER)}(.*?)#{Regexp.escape(END_MARKER)}/m

    def self.call(...)
      new(...).call
    end

    def initialize(generator:, folder_path:, force: false)
      @generator = generator
      @folder_path = folder_path
      @force = force
    end

    def call
      FileUtils.mkdir_p(@folder_path)
      results = @generator.call
      results.each { |result| save_result(result) }
    end

    private

    def save_result(result)
      path = Rails.root.join(@folder_path, result.name)

      if @force || !File.exist?(path)
        File.open(path, "w") { |f| f.write(result.text) }
        return
      end

      existing_content = File.read(path)

      new_content = if manually_editable?(existing_content)
        replace_between(
          existing: existing_content,
          new: result.text,
        )
      else
        result.text
      end

      File.open(path, "w") { |f| f.write(new_content) }
    end

    def manually_editable?(text)
      !text.match(REGEX).nil?
    end

    def replace_between(existing:, new:)
      new_content = extract_between(new)
      raise "Was @generator initialized with manually_editable: false?" unless new_content

      existing.gsub(REGEX, "#{START_MARKER}\n#{new_content}\n#{END_MARKER}")
    end

    def extract_between(text)
      match = text.match(REGEX)
      match[1].strip
    end
  end
end

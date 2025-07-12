module Anchor::TypeScript
  class MultifileSaveService
    START_MARKER = "// START AUTOGEN\n"
    END_MARKER = "\n// END AUTOGEN\n"
    REGEX = /#{Regexp.escape(START_MARKER)}(.*?)#{Regexp.escape(END_MARKER)}/m

    def self.call(...)
      new(...).call
    end

    def initialize(generator:, folder_path:, force: false, trust_hash: true)
      @generator = generator
      @folder_path = folder_path
      @force = force
      @trust_hash = trust_hash
    end

    def call
      FileUtils.mkdir_p(@folder_path)
      results = @generator.call
      modified_files = results.filter_map { |result| save_result(result) }
      save_sha
      modified_files
    end

    private

    def sha_hash_path
      Rails.root.join(@folder_path, "hash.json")
    end

    def sha_hash
      return @sha_hash if defined?(@sha_hash)

      @sha_hash = File.exist?(sha_hash_path) ? JSON.parse(File.read(sha_hash_path)) : {}
    end

    def save_sha
      File.open(sha_hash_path, "w") { |f| f.write(@generator.sha_hash.to_json) }
    end

    # @return [String, nil] file name of file that is written to. nil if not written to
    def save_result(result)
      path = Rails.root.join(@folder_path, result.name)

      if @force || !File.exist?(path)
        File.open(path, "w") { |f| f.write(result.text) }
        return result.name
      end

      return if @trust_hash && sha_hash[result.name] == Digest::SHA256.hexdigest(result.text)

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
      result.name
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

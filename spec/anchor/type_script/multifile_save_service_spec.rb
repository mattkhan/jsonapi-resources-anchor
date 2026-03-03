require "rails_helper"

RSpec.describe Anchor::TypeScript::MultifileSaveService do
  it "writes hash.json with prettier-compatible formatting" do
    Dir.mktmpdir do |tmp_dir|
      sha = { "foo.ts" => "abc123", "bar.ts" => "def456" }
      generator = double(call: [], sha_hash: sha)

      described_class.call(generator:, folder_path: tmp_dir)

      expected = <<~JSON
        {
          "foo.ts": "abc123",
          "bar.ts": "def456"
        }
      JSON
      expect(File.read(File.join(tmp_dir, "hash.json"))).to eq expected
    end
  end
end

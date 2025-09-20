class AddWithParsedCommentToExhaustives < ActiveRecord::Migration[8.0]
  def change
    comment = <<~JSON
      {
        "description": "This is a parsed JSON comment.",
        "test": 2
      }
    JSON
    add_column :exhaustives, :with_parsed_comment, :string, comment:
  end
end

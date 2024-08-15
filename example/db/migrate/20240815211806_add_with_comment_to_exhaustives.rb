class AddWithCommentToExhaustives < ActiveRecord::Migration[7.1]
  def change
    add_column :exhaustives, :with_comment, :string, comment: "This is a comment."
  end
end

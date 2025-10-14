class AddCommentToExhaustivesEnum < ActiveRecord::Migration[8.0]
  def change
    change_column_comment :exhaustives, :enum, from: nil, to: "This is an enum comment."
  end
end

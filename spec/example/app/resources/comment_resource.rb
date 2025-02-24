class CommentResource < ApplicationResource
  attribute :text
  attribute :created_at
  attribute :updated_at

  relationship :user, to: :one, description: "Author of the comment."
  relationship :deleted_by, to: :one, class_name: "User"
  relationship :commentable, polymorphic: true, to: :one

  def self.anchor_fetchable_fields(context)
    case context[:role]
    when "test" then fields - [:user, :text]
    else [:created_at]
    end
  end
end

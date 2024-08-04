class CommentResource < ApplicationResource
  attribute :text
  attribute :created_at
  attribute :updated_at
 
  relationship :user, to: :one
  relationship :deleted_by, to: :one, class_name: "User"
  relationship :commentable, Types::Relationship.new(resources: [UserResource, PostResource], null: true), polymorphic: true, to: :one

  def self.fetchable_fields(context)
    case context[:role]
    when 'test' then fields - [:user, :text]
    else [:created_at]
    end
  end
end

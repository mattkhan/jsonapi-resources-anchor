class CommentResource < ApplicationResource
  attribute :text
  attribute :created_at
  attribute :updated_at
 
  relationship :user, to: :one
  relationship :commentable, TSSchema::Types::Relationship.new(resources: [UserResource, PostResource], null: true), polymorphic: true, to: :one

  def self.fetchable_fields(context)
    case context[:role]
    when 'test' then fields - [:user, :text]
    else [:created_at]
    end
  end
end

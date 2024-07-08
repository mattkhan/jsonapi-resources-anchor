class CommentResource < ApplicationResource
  attribute :text
  attribute :created_at
  attribute :updated_at
 
  relationship :user, to: :one
  relationship :commentable, TSSchema::Types::Relationship.new(resources: [UserResource, PostResource], null: true), polymorphic: true, to: :one
end

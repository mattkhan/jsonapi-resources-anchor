class PostResource < ApplicationResource
  attribute :description

  relationship :user, to: :one
  relationship :comments, to: :many
  relationship :participants, to: :many, class_name: "User"
end

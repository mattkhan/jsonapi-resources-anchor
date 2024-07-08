class PostResource < ApplicationResource
  attribute :description

  relationship :user, to: :one
  relationship :comments, to: :many
end

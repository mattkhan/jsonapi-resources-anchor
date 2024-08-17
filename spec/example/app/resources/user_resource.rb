class UserResource < ApplicationResource
  attribute :name
  attribute :role, UserRoleEnum

  relationship :comments, to: :many
  relationship :posts, to: :many
end

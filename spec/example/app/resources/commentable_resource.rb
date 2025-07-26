class CommentableResource < ApplicationResource
  anchor_exclude_from_schema reason: :polymorphic
end

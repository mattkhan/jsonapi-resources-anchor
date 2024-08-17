class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true, optional: true
  belongs_to :user
  belongs_to :deleted_by, class_name: 'User', optional: true
end

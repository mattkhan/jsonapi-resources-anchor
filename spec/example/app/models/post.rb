class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable
  has_many :participants, through: :comments, source: :user
end

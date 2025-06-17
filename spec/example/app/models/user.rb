class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  enum :role, {
    admin: "admin",
    conent_creator: "content_creator",
    external: "external",
    guest: "guest",
    system: "system",
  }
end

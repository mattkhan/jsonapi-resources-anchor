class User < ApplicationRecord
  has_many :posts
  has_many :comments

  enum :role, {
    admin: "admin",
    conent_creator: "content_creator",
    external: "external",
    guest: "guest",
    system: "system",
  }
end

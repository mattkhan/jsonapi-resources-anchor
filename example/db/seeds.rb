# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#

class Seeder
  class << self
    def seed
      user = User.find_or_create_by!(name: "User", role: :admin)
      log(user)
      post = Post.find_or_create_by!(user:, description: "hi")
      log(post)
      comment = Comment.find_or_create_by!(user:, commentable: post, text: "hello")
      log(comment)
      exhaustive = create_exhaustive
      log(exhaustive)
    end

    def log(resource)
      puts "#{resource.class.name}: #{resource.id}"
    end

    def create_exhaustive
      time = Time.current
      attributes = {
        uuid: "36b32994-fe4e-4274-a8aa-33ffe6ae6f10",
        string: "string_value",
        maybe_string: nil,
        text: "text_value",
        integer: 1,
        float: 1.1,
        decimal: 1.11,
        datetime: time,
        timestamp: time,
        time: time,
        date: time,
        boolean: true,
        array_string: ["string_value"],
        maybe_array_string: nil,
        json: { key: "value" },
        jsonb: { key: "value", nested: { key: "value" } },
        daterange: time..(time + 10.days),
        enum: "sample",
      }

      Exhaustive.find_or_create_by!(uuid: attributes[:uuid]) do |exhaustive|
        exhaustive.assign_attributes(attributes)
      end
    end
  end
end

Seeder.seed

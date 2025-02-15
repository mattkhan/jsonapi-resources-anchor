# JSON:API Resource Schema Generation: Anchor

[Documentation](https://anchor-gem.vercel.app/docs)

Easily generate TypeScript schemas, JSON Schemas, or any schema of your choice
from [cerebris/jsonapi-resources](https://github.com/cerebris/jsonapi-resources)
`JSONAPI::Resource` classes.

Ideally, API schemas have the types of each payload fully specified.

`jsonapi-resources-anchor` provides:

- [Type inference](https://anchor-gem.vercel.app/docs/Features/type_inference)
  via the underlying ActiveRecord model of a resource
- [Type annotation](https://anchor-gem.vercel.app/docs/Features/type_annotation),
  e.g. `attribute :name_length, Anchor::Types::Integer`
- [Configuration](https://anchor-gem.vercel.app/docs/API/configuration), e.g.
  setting the case (camel, snake, etc.) of properties and deriving TypeScript
  comments from database comments
- TypeScript and JSON Schema generators via
  `Anchor::TypeScript::SchemaGenerator` and
  `Anchor::JSONSchema::SchemaGenerator`

See the [example](./spec/example) Rails app for a fully functional app using
`Anchor`.

## Installation

```ruby
gem 'jsonapi-resources-anchor'
```

```sh
bundle install
```

## TypeScript Demo

Given:

ActiveRecord Schema:

```rb
  create_table "comments", force: :cascade do |t|
    t.string "text", null: false
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.bigint "user_id", null: false
    t.bigint "deleted_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["deleted_by_id"], name: "index_comments_on_deleted_by_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "description", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.integer "integer"
    t.decimal "decimal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
  end
```

`JSONAPI::Resource` classes:

```rb
class ApplicationResource < JSONAPI::Resource
  abstract
  include Anchor::SchemaSerializable
end

class CommentResource < ApplicationResource
  attribute :text
  attribute :created_at
  attribute :updated_at
  attribute :inferred_unknown
  attribute :type_given, Anchor::Types::String

  relationship :user, to: :one
  relationship :commentable, Anchor::Types::Relationship.new(resources: [UserResource, PostResource], null: true), polymorphic: true, to: :one
end

class UserResource < ApplicationResource
  attribute :name
  attribute :role, UserRoleEnum

  relationship :comments, to: :many
  relationship :posts, to: :many
end

class UserRoleEnum < Anchor::Types::Enum
  anchor_schema_name "UserRole"

  value :admin, "admin"
  value :content_creator, "content_creator"
  value :external, "external"
  value :guest, "guest"
  value :system, "system"
end

class PostResource < ApplicationResource
  attribute :description

  relationship :user, to: :one
  relationship :comment, to: :many
end

class Schema < Anchor::Schema
  resource CommentResource
  resource UserResource
  resource PostResource

  enum UserRoleEnum
end
```

`Anchor::TypeScript::SchemaGenerator.call(register: Schema.register)` will
return the schema below in a `String`:

```ts
type Maybe<T> = T | null;

export type Comment = {
  id: number;
  type: "comments";
  text: string;
  created_at: string;
  updated_at: string;
  inferred_unknown: unknown;
  type_given: string;
  relationships: {
    user: User;
    commentable: Maybe<User | Post>;
  };
};

export type User = {
  id: number;
  type: "users";
  name: string;
  role: UserRole;
  relationships: {
    comments: Array<Comment>;
    posts: Array<Post>;
  };
};

export type Post = {
  id: number;
  type: "posts";
  description: string;
  relationships: {
    user: User;
    comment: Array<Comment>;
  };
};

export enum UserRole {
  Admin = "admin",
  ContentCreator = "content_creator",
  External = "external",
  Guest = "guest",
  System = "system",
}
```

#### References

- [@nopelluhh](https://github.com/nopelluhh)
- [ElMassimo/types_from_serializers](https://github.com/ElMassimo/types_from_serializers)
- [rmosolgo/graphql-ruby](https://github.com/rmosolgo/graphql-ruby)

#### Security

[Security Policy](/SECURITY.md)

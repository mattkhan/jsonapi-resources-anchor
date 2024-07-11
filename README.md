# JSON:API TypeScript Schema Generation

Generate TypeScript types from [cerebris/jsonapi-resources](https://github.com/cerebris/jsonapi-resources) `JSONAPI::Resource`s.

## Example

Given:

<details>
  <summary>ActiveRecord Schema</summary>

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

</details>

`JSONAPI::Resource`s:

```rb
class CommentResource < ApplicationResource
  attribute :text
  attribute :created_at
  attribute :updated_at
  attribute :inferred_unknown
  attribute :type_given, TSSchema::Types::String

  relationship :user, to: :one
  relationship :commentable, TSSchema::Types::Relationship.new(resources: [UserResource, PostResource], null: true), polymorphic: true, to: :one
end

class UserResource < ApplicationResource
  attribute :name
  attribute :role, UserRoleEnum

  relationship :comments, to: :many
  relationship :posts, to: :many
end

class UserRoleEnum < TSSchema::Types::Enum
  schema_name "UserRole"

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

class Schema < TSSchema::Schema
  resource CommentResource
  resource UserResource
  resource PostResource

  enum UserRoleEnum
end
```

`Schema.generate` will return the schema below in a `String`:

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

### Type Inference

`JSONAPI::Resource.attributes` will have their types inferred from the resource's associated `ActiveRecord` model.

SQL type mapping [here](./lib/ts_schema/types.rb?plain=1#L134).

- credit to [ElMassimo/types_from_serializers](https://github.com/ElMassimo/types_from_serializers) for the approach

`JSONAPI::Resource._relationships` will use the relationship's associated `JSONAPI::Resource`'s `schema_name` attribute as the type identifier.

- credit to [rmosolgo/graphql-ruby](https://github.com/rmosolgo/graphql-ruby) for the `schema_name` API approach

If the type can't be inferred: specify a type as described in [TSSchema::Resource](#tsschemaresource).

## Guides

### `TSSchema::Resource`

```rb
class SomeScope::UserResource
  # optional schema_name definition
  # defaults to part of the string after the last :: (or class name itself if not nested) and removes Resource, in this case User
  schema_name "SpecialUser"

  attribute :name
  attribute :role, TSSchema::Types::String

  relationship :profile, to: :one
  relationship :group, TSSchema::Types::Relationship.new(resource: GroupResource, null: true), to: :one
end
```

The APIs of `JSONAPI::Resource.attribute` and `JSONAPI::Resource.relationship` have been modified to take in an optional type parameter.

If the type can be inferred from the underlying ActiveRecord model the type argument isn't required.

If there is no type argument and the type cannot be inferred, then the type of the property will default to `unknown`.

The type argument has precedence over the inferred type.

For `.attribute`:

- after the `name` argument, specify any type from the table in [TSSchema::Types](#tsschematypes)

For `.relationship`:

- after the `name` argument, specify a `TSSchema::Types::Relationship`

The APIs of `JSONAPI::Resource.attribute` and `JSONAPI::Resource.relationship` remain the same if a type argument is not given.

If a type argument is given, the `options` for each will be the third argument.

`TSSchema::Resource.to_ts_type_string` returns a `String` with the generated type. See [example](#example-1).

### `TSSchema::Types::Enum`

```rb
class UserRoleEnum < TSSchema::Types::Enum
  schema_name "UserRole" # optional, similar logic to Resource but removes Enum

  # First argument is the enum member identifier that gets camelized
  # Second argument is the value
  value :admin, "admin"
  value :content_creator, "content_creator"
  value :external, "external"
  value :guest, "guest"
  value :system, "system"
end
```

`TSSchema::Types::Enum.to_ts_type_string` returns a `String` with the generated type.

Very similar to [rmosolgo/graphql-ruby](https://github.com/rmosolgo/graphql-ruby) enums.

### `TSSchema::Schema`

```rb
class Schema < TSSchema::Schema
  resource CommentResource # register resources
  resource UserResource
  resource PostResource

  enum UserRoleEnum # register enums
end
```

`Schema.generate` will return the schema in a `String`.

Note: Currently, dependent resources and enums do not have their types generated. _All_ resources and enums must be registered as part of the schema.

### `TSSchema::Types`

| `TSSchema (type = Types::...)` | TypeScript type expression                                                |
| ------------------------------ | ------------------------------------------------------------------------- |
| `Types::String`                | `string`                                                                  |
| `Types::Number`                | `number`                                                                  |
| `Types::Boolean`               | `boolean`                                                                 |
| `Types::Null`                  | `null`                                                                    |
| `Types::Unknown`               | `unknown`                                                                 |
| `Types::Maybe.new(T)`          | `Maybe<T>`                                                                |
| `Types::Array.new(T)`          | `Array<T>`                                                                |
| `Types::Record`                | `Record<string, unknown>`                                                 |
| `Types::Record.new(T)`         | `Record<string, T>`                                                       |
| `Types::Reference.new(name)`   | `name` (directly used as type identifier)                                 |
| `Types::Literal.new(value)`    | `"#{value}"` if `string`, else `value.to_s`                               |
| `Types::Enum`                  | `type.schema_name` (directly used as type identifier)                     |
| `Types::Union.new(Ts)`         | `Ts[0] \| Ts[1] \| ...`                                                   |
| `Types::Object.new(props)`     | `{ [props[0].name]: props[0].type, [props[1].name]: props[1].type, ... }` |

```rb
module TSSchema::Types
  # @!attribute [r] resource
  #   @return [TSSchema::Resource, NilClass] the associated resource
  # @!attribute [r] resources
  #   @return [Array<TSSchema::Resource>, NilClass] union of associated resources
  # @!attribute [r] null
  #   @return [Boolean] whether the relationship can be `null`
  # @!attribute [r] null_elements
  #   @return [Boolean] whether the elements in a _many_ relationship can be `null`
  Relationship = Struct.new(:resource, :resources, :null, :null_elements, keyword_init: true)
end
```

#### Example

```rb
class CustomResource < TSSchema::Resource
  object = TSSchema::Types::Object.new([
    TSSchema::Types::Property.new(:a, TSSchema::Types::Literal.new("a")),
    TSSchema::Types::Property.new(:b, TSSchema::Types::Literal.new(1)),
    TSSchema::Types::Property.new(:c, TSSchema::Types::Maybe.new(TSSchema::Types::String)),
  ])

  attribute :string, TSSchema::Types::String
  attribute :number, TSSchema::Types::Number
  attribute :boolean, TSSchema::Types::Boolean
  attribute :null, TSSchema::Types::Null
  attribute :unknown, TSSchema::Types::Unknown
  attribute :maybe_object, TSSchema::Types::Maybe.new(object)
  attribute :array_record, TSSchema::Types::Array.new(TSSchema::Types::Record.new(TSSchema::Types::Number))
  attribute :union, TSSchema::Types::Union.new([TSSchema::Types::String, TSSchema::Types::Number])
end
```

`puts CustomResource.to_ts_type_string` generates

```ts
export type Custom = {
  id: number;
  type: "customs";
  string: string;
  number: number;
  boolean: boolean;
  null: null;
  unknown: unknown;
  maybe_object: Maybe<{
    a: "a";
    b: 1;
    c: Maybe<string>;
  }>;
  array_record: Array<Record<string, number>>;
  union: string | number;
};
```

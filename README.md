# JSON:API Resource Schema Generation: Anchor

Easily generate TypeScript schemas, JSON Schemas, or any schema of your choice
from [cerebris/jsonapi-resources](https://github.com/cerebris/jsonapi-resources)
`JSONAPI::Resource` classes.

Ideally, API schemas have the types of each payload fully specified.

To conveniently reach that ideal in a Ruby codebase that doesn't have static
type signatures, `Anchor` automates type inference for attributes and
relationships via the underlying ActiveRecord model of the `JSONAPI::Resource`.

If a type for an attribute or relationship can't be inferred or you'd like to
specify it statically, you can annotate the `attribute` or `relationship` via
types defined in `Anchor::Types`, see [Annotations](#annotations).

This gem provides TypeScript and JSON Schema generators with
`Anchor::TypeScript::SchemaGenerator` and `Anchor::JSONSchema::SchemaGenerator`.

See the [example](./example) Rails app for a fully functional example using
`Anchor`. See [schema_test.rb](./example/test/models/schema_test.rb) for
`Schema` generation examples.

## Inference

### Attributes

`JSONAPI::Resource` attributes are inferred via introspection of the resource's
underlying ActiveRecord model (`JSONAPI::Resources._model_class`).

`ActiveRecord::Base.columns_hash[attribute]` is used to get the SQL type and is
then mapped to an `Anchor::Type` in
`Anchor::Types::Inference::ActiveRecord::SQL.from`.

- `Anchor.config.ar_column_to_type` allows custom mappings, see
  [example/initializers/anchor.rb](./examples/initializers/anchor.rb)
- `Anchor.config.use_active_record_presence` can be set to `true` to infer
  nullable attributes (i.e. fields that do not specify `null: false` in
  schema.rb) as non-null when an unconditional
  `validates :attribute_name, presence: true` is present on the model

### Relationships

`JSONAPI::Resource` relationships refer to other `JSONAPI::Resource` classes, so
the `JSONAPI::Resource.anchor_schema_name` of the related relationship is used
as a reference in the TypeScript and JSON Schema adapters.

`Anchor` infers whether the associated resource is nullable or an array via
`JSONAPI::Resource._model_class.reflections[name]` where `name` is the first
element of the `JSONAPI::Resource._relationships` `[name, relationship]` tuples.

| ActiveRecord Association               | Inferred `Anchor::Type` |
| -------------------------------------- | ----------------------- |
| `belongs_to :relation`                 | `Relation`              |
| `belongs_to :relation, optional: true` | `Maybe<Relation>`       |
| `has_one :relation`                    | `Maybe<Relation>`       |
| `has_many :relations`                  | `Array<Relation>`       |
| `has_and_belogs_to_many :relations`    | `Array<Relation>`       |

- set `Anchor.config.infer_nullable_relationships_as_optional` to `true` to
  infer that the property associated with a nullable relationship will not be
  present if it's null
  - e.g. in TypeScript, setting the config to true will infer
    `{ relation?: Relation }` over `{ relation: Maybe<Relation> }`

## Annotations

The APIs of `JSONAPI::Resource.attribute` and `JSONAPI::Resource.relationship`
have been modified to take in an optional type parameter.

If the type can be inferred from the underlying ActiveRecord model the type
argument isn't required.

If there is no type argument and the type cannot be inferred, then the type of
the property will default to `unknown`.

The type argument has precedence over the inferred type.

For `.attribute`:

- after the `name` argument, specify any type from the table in
  [Anchor::Types](#anchortypes)

For `.relationship`:

- after the `name` argument, specify a `Anchor::Types::Relationship`

The APIs of `JSONAPI::Resource.attribute` and `JSONAPI::Resource.relationship`
remain the same if a type argument is not given.

If a type argument is given, the `options` for each will be the third argument.

## Generators

This gem provides generators for JSON Schema and TypeScript schemas via
`Schema.generate(adapter: :type_script | :json_schema)`.

### Custom Generator

You can create your own generator by providing it to
`Schema.generate(adapter: MyGenerator)`.

It should inherit from `Anchor::SchemaGenerator`, e.g.

```rb
class MyGenerator < Anchor::SchemaGenerator
  def call
    raise NotImplementedError
  end
end
```

See `Anchor::TypeScript::Resource`, `Anchor::TypeScript::Serializer`, and
`Anchor::TypeScript::SchemaGenerator` and the equivalents under
`Anchor::JSONSchema` for examples.

## Configuration

| Name                                       | Type                         | Description                                                                                                                                        |
| ------------------------------------------ | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| `field_case`                               | `:camel \| :snake \| :kebab` | Case format for `attributes` and `relationships` properties.                                                                                       |
| `ar_column_to_type`                        | `Proc`                       | `ActiveRecord::Base.columns_hash[attribute]` to `Anchor::Type`                                                                                     |
| `use_active_record_presence`               | `Boolean`                    | check presence of unconditional `validates :attribute, presence: true` to infer database nullable attribute as non-null                            |
| `infer_nullable_relationships_as_optional` | `Boolean`                    | `true` infers nullable relationships as optional. e.g. in TypeScript, `true` infers `{ relation?: Relation }` over `{ relation: Maybe<Relation> }` |

## Guides

### Create a schema serializable resource

```rb
class ApplicationResource
  include Anchor::SchemaSerializable
end

class SomeScope::UserResource < ApplicaionResource
  # optional schema_name definition
  # defaults to part of the string after the last :: (or class name itself if not nested) and removes Resource, in this case User
  schema_name "SpecialUser"

  attribute :name
  attribute :role, Anchor::Types::String

  relationship :profile, to: :one
  relationship :group, Anchor::Types::Relationship.new(resource: GroupResource, null: true), to: :one
end
```

### `Anchor::Schema`

```rb
class Schema < Anchor::Schema
  resource CommentResource # register resources
  resource UserResource
  resource PostResource

  enum UserRoleEnum # register enums
end
```

`Schema.generate` will return the schema in a `String`.

Note: Currently, dependent resources and enums do not have their types
generated. _All_ resources and enums must be registered as part of the schema.

### `Anchor::Types`

| `Anchor (type = Types::...)` | TypeScript type expression                                                |
| ---------------------------- | ------------------------------------------------------------------------- |
| `Types::String`              | `string`                                                                  |
| `Types::Integer`             | `number`                                                                  |
| `Types::Float`               | `number`                                                                  |
| `Types::BigDecimal`          | `string`                                                                  |
| `Types::Boolean`             | `boolean`                                                                 |
| `Types::Null`                | `null`                                                                    |
| `Types::Unknown`             | `unknown`                                                                 |
| `Types::Maybe.new(T)`        | `Maybe<T>`                                                                |
| `Types::Array.new(T)`        | `Array<T>`                                                                |
| `Types::Record`              | `Record<string, unknown>`                                                 |
| `Types::Record.new(T)`       | `Record<string, T>`                                                       |
| `Types::Reference.new(name)` | `name` (directly used as type identifier)                                 |
| `Types::Literal.new(value)`  | `"#{value}"` if `string`, else `value.to_s`                               |
| `Types::Enum`                | `Enum.anchor_schema_name` (directly used as type identifier)              |
| `Types::Union.new(Ts)`       | `Ts[0] \| Ts[1] \| ...`                                                   |
| `Types::Object.new(props)`   | `{ [props[0].name]: props[0].type, [props[1].name]: props[1].type, ... }` |

Note: The TypeScript type expression is derived from the
`Anchor::TypeScript::Serializer` this gem provides for TypeScript schema
generation. See `Anchor::JSONSchema::Serializer` for the given JSON Schema
generator.

```rb
module Anchor::Types
  # @!attribute [r] resource
  #   @return [JSONAPI::Resource, NilClass] the associated resource
  # @!attribute [r] resources
  #   @return [Array<JSONAPI::Resource>, NilClass] union of associated resources
  # @!attribute [r] null
  #   @return [Boolean] whether the relationship can be `null`
  # @!attribute [r] null_elements
  #   @return [Boolean] whether the elements in a _many_ relationship can be `null`
  Relationship = Struct.new(:resource, :resources, :null, :null_elements, keyword_init: true)
end
```

#### `Anchor::Types::Enum`

```rb
class UserRoleEnum < Anchor::Types::Enum
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

Very similar to
[rmosolgo/graphql-ruby](https://github.com/rmosolgo/graphql-ruby) enums.

## Example

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
class ApplicaionResource
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

class Schema < Anchor::Schema
  resource CommentResource
  resource UserResource
  resource PostResource

  enum UserRoleEnum
end
```

`Schema.generate(adapter: :type_script)` will return the schema below in a
`String`:

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

- [ElMassimo/types_from_serializers](https://github.com/ElMassimo/types_from_serializers)
- [rmosolgo/graphql-ruby](https://github.com/rmosolgo/graphql-ruby)

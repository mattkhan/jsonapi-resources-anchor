class Schema < TSSchema::Schema
  resource CommentResource
  resource UserResource
  resource PostResource
  resource ExhaustiveResource

  enum UserRoleEnum
end

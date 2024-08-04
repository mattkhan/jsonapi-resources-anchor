class UserRoleEnum < Types::Enum
  anchor_schema_name "UserRole"

  value :admin, "admin"
  value :content_creator, "content_creator"
  value :external, "external"
  value :guest, "guest"
  value :system, "system"
end

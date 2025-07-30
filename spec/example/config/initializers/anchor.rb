module Anchor
  configure do |c|
    c.field_case = :camel_without_inflection
    c.use_active_record_comment = true
    c.use_active_record_validations = true
    c.infer_default_as_non_null = true
    c.infer_nullable_relationships_as_optional = true

    c.ar_column_to_type = lambda { |column|
      return Types::Literal.new("never") if column.name == "loljk"
      Types::Inference::ActiveRecord::SQL.default_ar_column_to_type(column)
    }

    c.empty_relationship_type = -> { Anchor::Types::Object }
  end
end

JSONAPI.configure do |c|
  c.json_key_format = :camelized_key
end

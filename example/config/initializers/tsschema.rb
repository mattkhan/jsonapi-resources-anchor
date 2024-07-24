module TSSchema
  configure do |c|
    c.field_case = :camel
    c.use_active_record_presence = true
    c.infer_nullable_relationships_as_optional = true

    c.ar_column_to_type = lambda { |column|
      return Types::Reference.new("never") if column.name == 'loljk'
      Types::SQL.default_ar_column_to_type(column)
    }
  end
end

JSONAPI.configure do |c|
  c.json_key_format = :camelized_key
end

module Anchor
  configure do |c|
    c.field_case = :camel_without_inflection
    c.use_active_record_comment = true
    c.use_active_record_validations = true
    c.infer_default_as_non_null = true
    c.infer_nullable_relationships_as_optional = true
    c.infer_ar_enums = true
    c.rbs = "fallback"

    c.ar_column_to_type = lambda { |column|
      return Types::Literal.new("never") if column.name == "loljk"
      Types::Inference::ActiveRecord::SQL.default_ar_column_to_type(column)
    }
    c.ar_comment_to_string = lambda { |comment|
      begin
        res = JSON.parse(comment)
        res["description"]
      rescue JSON::ParserError
        comment
      end
    }

    c.empty_relationship_type = -> { Anchor::Types::Object }
    c.rbs_sig_path = Rails.root.join("sig")
  end
end

JSONAPI.configure do |c|
  c.json_key_format = :camelized_key
end

module Anchor
  class Config
    attr_accessor :ar_column_to_type,
      :field_case,
      :use_active_record_validations,
      :use_active_record_comment,
      :infer_nullable_relationships_as_optional,
      :empty_relationship_type,
      :use_type_as_schema_name,
      :maybe_as_union,
      :array_bracket_notation,
      :infer_default_as_non_null,
      :ar_comment_to_string

    def initialize
      @ar_column_to_type = nil
      @field_case = nil
      @use_active_record_validations = true
      @use_active_record_comment = nil
      @infer_nullable_relationships_as_optional = nil
      @empty_relationship_type = nil
      @use_type_as_schema_name = nil
      @maybe_as_union = nil
      @array_bracket_notation = nil
      @infer_default_as_non_null = nil
      @ar_comment_to_string = nil
    end
  end
end

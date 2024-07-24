module TSSchema
  class Config
    attr_accessor :ar_column_to_type, :field_case, :use_active_record_presence, :infer_nullable_relationships_as_optional

    def initialize
      @ar_column_to_type = nil
      @field_case = nil
      @use_active_record_presence = nil
      @infer_nullable_relationships_as_optional = nil
    end
  end
end

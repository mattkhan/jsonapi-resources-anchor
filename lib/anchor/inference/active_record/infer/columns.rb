module Anchor::Inference::ActiveRecord::Infer
  class Columns < Base
    def infer = object(properties)

    private

    def properties
      @klass.columns_hash.map do |name, column|
        next property(name, Anchor.config.ar_column_to_type.call(column)) if Anchor.config.ar_column_to_type
        metadata_type = from_sql_type_metadata(column.sql_type_metadata)
        column_type = from_column_type(column.type)

        type = [metadata_type, column_type, unknown].compact.first
        type = column.null ? maybe(type) : type
        property(name, type)
      end
    end

    def from_sql_type_metadata(sql_type_metadata)
      case sql_type_metadata.sql_type
      when "character varying[]", "text[]" then array(string)
      end
    end

    def from_column_type(type)
      case type
      when :boolean then boolean
      when :date then string
      when :datetime then string
      when :decimal then big_decimal
      when :float then float
      when :integer then integer
      when :json then record
      when :jsonb then record
      when :string then string
      when :text then string
      when :time then string
      when :uuid then string
      end
    end
  end
end

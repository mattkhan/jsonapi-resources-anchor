module Anchor::Types::Inference
  module ActiveRecord
    module SQL
      class << self
        def default_ar_column_to_type(column)
          metadata_type = from_sql_type_metadata(column.sql_type_metadata)
          column_type = from_column_type(column.type)

          type = [metadata_type, column_type, Anchor::Types::Unknown].compact.first

          column.null ? Anchor::Types::Maybe.new(type) : type
        end

        private

        def from_sql_type_metadata(sql_type_metadata)
          case sql_type_metadata.sql_type
          when "character varying[]", "text[]" then Anchor::Types::Array.new(Anchor::Types::String)
          end
        end

        # inspiration from https://github.com/ElMassimo/types_from_serializers/blob/146ba40bc1a0da37473cd3b705a8ca982c2d173f/types_from_serializers/lib/types_from_serializers/generator.rb#L382
        def from_column_type(type)
          case type
          when :boolean then Anchor::Types::Boolean
          when :date then Anchor::Types::String
          when :datetime then Anchor::Types::String
          when :decimal then Anchor::Types::BigDecimal
          when :float then Anchor::Types::Float
          when :integer then Anchor::Types::Integer
          when :json then Anchor::Types::Record
          when :jsonb then Anchor::Types::Record
          when :string then Anchor::Types::String
          when :text then Anchor::Types::String
          when :time then Anchor::Types::String
          when :uuid then Anchor::Types::String
          end
        end
      end
    end
  end
end

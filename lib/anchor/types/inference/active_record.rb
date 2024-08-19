module Anchor::Types::Inference
  module ActiveRecord
    class << self
      # rubocop:disable Layout/LineLength

      # @return [Proc{Type => Type, Anchor::Types::Maybe<Type>, Anchor::Types::Array<Type>}]
      def wrapper_from_reflection(reflection)
        case reflection
        when ::ActiveRecord::Reflection::BelongsToReflection then ->(type) { belongs_to_type(reflection, type) }
        when ::ActiveRecord::Reflection::HasOneReflection then ->(type) { Anchor::Types::Maybe.new(type) }
        when ::ActiveRecord::Reflection::HasManyReflection then ->(type) { Anchor::Types::Array.new(type) }
        when ::ActiveRecord::Reflection::HasAndBelongsToManyReflection then ->(type) { Anchor::Types::Array.new(type) }
        when ::ActiveRecord::Reflection::ThroughReflection then wrapper_from_reflection(reflection.send(:delegate_reflection))
        else raise "#{reflection.class.name} not supported"
        end
      end
      # rubocop:enable Layout/LineLength

      private

      # @param reflection [::ActiveRecord::Reflection::BelongsToReflection]
      # @param type [Anchor::Types]
      # @return [Anchor::Types::Maybe<Type>, Type]
      def belongs_to_type(reflection, type)
        reflection.options[:optional] ? Anchor::Types::Maybe.new(type) : type
      end
    end

    module SQL
      class << self
        def from(column, check_config: true)
          return Anchor.config.ar_column_to_type.call(column) if check_config && Anchor.config.ar_column_to_type
          type = from_sql_type(column.type)

          if column.sql_type_metadata.sql_type == "character varying[]"
            type = Anchor::Types::Array.new(Anchor::Types::String)
          end

          column.null ? Anchor::Types::Maybe.new(type) : type
        end

        def default_ar_column_to_type(column)
          from(column, check_config: false)
        end

        private

        # inspiration from https://github.com/ElMassimo/types_from_serializers/blob/146ba40bc1a0da37473cd3b705a8ca982c2d173f/types_from_serializers/lib/types_from_serializers/generator.rb#L382
        def from_sql_type(type)
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
          else Anchor::Types::Unknown
          end
        end
      end
    end
  end
end

module Anchor::Types::Inference
  module ActiveRecord
    class << self
      # @return [Proc{Type => Type, Anchor::Types::Maybe<Type>, Anchor::Types::Array<Type>}]
      def wrapper_from_reflection(reflection)
        case reflection
        when ::ActiveRecord::Reflection::BelongsToReflection then ->(type) { belongs_to_type(reflection, type) }
        when ::ActiveRecord::Reflection::HasOneReflection then ->(type) { Types::Maybe.new(type) }
        when ::ActiveRecord::Reflection::HasManyReflection then ->(type) { Types::Array.new(type) }
        when ::ActiveRecord::Reflection::HasAndBelongsToManyReflection then ->(type) { Types::Array.new(type) }
        when ::ActiveRecord::Reflection::ThroughReflection then wrapper_from_reflection(reflection.send(:delegate_reflection))
        else raise RuntimeError.new("#{reflection.class.name} not supported")
        end
      end

      private
      # @param reflection [::ActiveRecord::Reflection::BelongsToReflection]
      # @param type [Anchor::Types]
      # @return [Anchor::Types::Maybe<Type>, Type]
      def belongs_to_type(reflection, type)
        reflection.options[:optional] ? Types::Maybe.new(type) : type
      end
    end

    module SQL
      class << self
        def from(column, check_config: true)
          return Anchor.config.ar_column_to_type.call(column) if check_config && Anchor.config.ar_column_to_type
          type = from_sql_type(column.type)

          if column.sql_type_metadata.sql_type == 'character varying[]'
            type = Types::Array.new(Types::String)
          end

          column.null ? Types::Maybe.new(type) : type
        end

        def default_ar_column_to_type(column)
          from(column, check_config: false)
        end

        private

        # inspiration from https://github.com/ElMassimo/types_from_serializers/blob/146ba40bc1a0da37473cd3b705a8ca982c2d173f/types_from_serializers/lib/types_from_serializers/generator.rb#L382
        def from_sql_type(type)
          case type
          when :boolean then Types::Boolean
          when :date then Types::String
          when :datetime then Types::String
          when :decimal then Types::BigDecimal
          when :float  then Types::Float
          when :integer then Types::Integer
          when :json then Types::Record
          when :jsonb then Types::Record
          when :string then Types::String
          when :text then Types::String
          when :time then Types::String
          when :uuid then Types::String
          else Types::Unknown
          end
        end
      end
    end
  end
end

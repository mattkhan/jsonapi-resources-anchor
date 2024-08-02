module TSSchema
  module Types
    class String; end
    class Number; end
    class Boolean; end
    class Null; end
    class Unknown; end

    # @!attribute [r] value_type
    #   @return [TSSchema::Types] the types supported in {type_string}
    Record = Struct.new(:value_type)

    # @!attribute [r] type
    #   @return [TSSchema::Types] the types supported in {type_string}
    Maybe = Struct.new(:type)

    # @!attribute [r] type
    #   @return [TSSchema::Types] the types supported in {type_string}
    Array = Struct.new(:type)

    # @!attribute [r] value
    #   @return [Object]
    Literal = Struct.new(:value)

    # @!attribute [r] type
    #   @return [Array<TSSchema::Types>] the types supported in {type_string}
    Union = Struct.new(:types)

    # @!attribute [r] name
    #   @return [String] type identifier
    Reference = Struct.new(:name)

    # @!attribute [r] properties
    #   @return [Array<TSSchema::Types::Property>]
    Object = Struct.new(:properties)

    # @!attribute [r] name
    #   @return [String, Symbol]
    # @!attribute [r] type
    #   @return [TSSchema::Types] the types supported in {type_string}
    Property = Struct.new(:name, :type, :optional) do
      def format_key!
        self.name = case TSSchema.config.field_case
        when :camel then name.to_s.underscore.camelize(:lower)
        when :kebab then name.to_s.underscore.dasherize
        when :snake then name.to_s.underscore
        else self.name
        end

        self
      end

      def safe_name
        name.match?(/[^a-zA-Z0-9_]/) ? "\"#{name}\"" : name.to_s + (optional ? "?" : "")
      end
    end

    # @!attribute [r] resource
    #   @return [TSSchema::Resource, NilClass] the associated resource
    # @!attribute [r] resources
    #   @return [Array<TSSchema::Resource>, NilClass] union of associated resources
    # @!attribute [r] null
    #   @return [Boolean] whether the relationship can be `null`
    # @!attribute [r] null_elements
    #   @return [Boolean] whether the elements in a _many_ relationship can be `null`
    Relationship = Struct.new(:resource, :resources, :null, :null_elements, keyword_init: true)

    class Enum
      class << self
        # @param name [String] The type identifier to be used in the schema.
        # @return [String]
        def schema_name(name = nil)
          @schema_name ||= name || default_schema_name
        end

        # Defines a member of the enum.
        # @param name [String] the enum member identifier
        # @param value [Object] the value of the enum
        def value(name, value)
          @values ||= []
          @values.push([name, Types::Literal.new(value)])
        end

        # @return [String]
        def to_ts_type_string
          ["export enum #{schema_name} {", named_constants, "}"].join("\n")
        end

        private

        def named_constants
          @values.map { |name, value| "  #{name.to_s.camelize} = #{Types.type_string(value)}," }.join("\n")
        end

        def default_schema_name
          s_name = name.split("::").last
          s_name.end_with?("Enum") ? s_name.sub(/Enum\Z/, "") : s_name
        end
      end
    end

    class << self
      def type_string(type, depth=1)
        case type
        when String, String.singleton_class then "string"
        when Number, Number.singleton_class then "number"
        when Boolean, Boolean.singleton_class then "boolean"
        when Null, Null.singleton_class then "null"
        when Record, Record.singleton_class then "Record<string, #{type_string(type.try(:value_type) || Unknown)}>"
        when Union then type.types.map { |type| type_string(type, depth) }.join(' | ')
        when Maybe then "Maybe<#{type_string(type.type, depth)}>"
        when Array then "Array<#{type_string(type.type, depth)}>"
        when Literal then serialize_literal(type.value)
        when Reference then type.name
        when Object then serialize_object(type, depth)
        when Enum, Enum.singleton_class then type.schema_name
        when Unknown, Unknown.singleton_class then "unknown"
        else raise RuntimeError
        end
      end

      private

      def serialize_literal(value)
        case value
        when ::String, ::Symbol then "\"#{value}\""
        else value.to_s
        end
      end

      def serialize_object(type, depth)
        properties = type.properties.map { |p| "#{p.safe_name}: #{type_string(p.type, depth + 1)};" }
        indent = " " * (depth * 2)
        properties = properties.map { |p| p.prepend(indent) }.join("\n")
        ["{", properties, "}".prepend(indent[2..])].join("\n")
      end
    end

    module SQL
      class << self
        def from(column, check_config: true)
          return TSSchema.config.ar_column_to_type.call(column) if check_config && TSSchema.config.ar_column_to_type
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
          when :decimal then Types::String
          when :float  then Types::Number
          when :integer then Types::Number
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

    module ActiveRecord
      class << self
        # @return [Proc{Type => Type, TSSchema::Types::Maybe<Type>, TSSchema::Types::Array<Type>}]
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
        # @param type [TSSchema::Types]
        # @return [TSSchema::Types::Maybe<Type>, Type]
        def belongs_to_type(reflection, type)
          reflection.options[:optional] ? Types::Maybe.new(type) : type
        end
      end
    end

    module JSONAPI
      class << self
        # @return [Proc{Type => Type, TSSchema::Types::Array<Type>}]
        def wrapper_from_relationship(relationship)
          case relationship
          when ::JSONAPI::Relationship::ToOne then ->(type) { type }
          when ::JSONAPI::Relationship::ToMany then ->(type) { Types::Array.new(type) }
          else raise RuntimeError.new("#{relationship.class.name} not supported")
          end
        end
      end
    end
  end
end

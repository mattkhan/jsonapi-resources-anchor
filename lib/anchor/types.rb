module Anchor
  module Types
    class String; end
    class Float; end
    class Integer; end
    class BigDecimal; end
    class Boolean; end
    class Null; end
    class Unknown; end
    Identity = Data.define(:type)
    Record = Data.define(:value_type)
    Maybe = Data.define(:type)
    Array = Data.define(:type)
    Literal = Data.define(:value) do
      def [](value)
        new(value)
      end
    end
    Union = Data.define(:types) do
      def |(other)
        self.class.new(types + [other])
      end
    end
    Intersection = Data.define(:types)
    Reference = Data.define(:name) do
      def anchor_schema_name = name

      def |(other)
        Anchor::Types::Union.new([self, other])
      end
    end

    Property = Data.define(:name, :type, :optional, :description) do
      def initialize(name:, type:, optional: false, description: nil)
        super
      end

      def dup(name: nil, type: nil, optional: nil, description: nil)
        self.class.new(
          name: name || self.name,
          type: type || self.type,
          optional: optional.nil? ? self.optional : optional,
          description: description || self.description,
        )
      end
    end

    class Object
      attr_reader :properties, :properties_hash

      delegate :[], :keys, :key?, to: :properties_hash

      def initialize(properties)
        @properties = properties || []
        @properties_hash = properties.index_by(&:name) || []
      end

      def pick(keys)
        picked = properties_hash.slice(*keys).values
        self.class.new(picked)
      end

      def omit(keys)
        omitted = properties_hash.except(*keys).values
        self.class.new(omitted)
      end

      def pick_by_value(t)
        props = properties.filter { |prop| prop.type.is_a?(t) }
        self.class.new(props)
      end

      def untype(names = nil)
        names ||= keys
        pick(names).overwrite_values(Anchor::Types::Unknown) + omit(names)
      end

      def overwrite_values(type)
        props = properties.map { |prop| prop.dup(type:) }
        self.class.new(props)
      end

      def apply_higher(other, keep_description: :right)
        props = properties.filter_map do |prop|
          if (other_prop = other[prop.name])
            desc = keep_description == :right ? other_prop.description : property.description
            Property.new(prop.name, other_prop.type.new(prop.type), prop.optional, desc)
          else
            prop
          end
        end
        self.class.new(props)
      end

      def overwrite(other, keep_description: :right)
        props = properties.map do |prop|
          if (other_prop = other[prop.name])
            description = keep_description == :left ? prop.description : other_prop.description
            other_prop.dup(description:)
          else
            prop.dup
          end
        end
        self.class.new(props)
      end

      # left-based union
      def +(other)
        self.class.new(properties + other.omit(keys).properties)
      end

      def transform_keys
        props = properties.map { |prop| prop.dup(name: yield(prop.name)) }
        self.class.new(props)
      end

      def camelize
        transform_keys { |name| Anchor::Types.camelize_without_inflection(name) }
      end

      def convert_case
        transform_keys { |name| Anchor::Types.convert_case(name) }
      end

      def nonnullable
        props = properties.map do |prop|
          next prop unless prop.type.is_a?(Anchor::Types::Maybe)
          prop.dup(type: prop.type.type)
        end
        self.class.new(props)
      end

      def nullable_to_optional
        props = properties.map do |prop|
          next prop unless prop.type.is_a?(Anchor::Types::Maybe)
          prop.dup(type: prop.type.type, optional: true)
        end
        self.class.new(props)
      end

      class << self
        def properties
          @properties ||= []
        end

        def property(name, type, optional: nil, description: nil)
          @properties ||= []
          @properties.push(Property.new(name, type, optional, description))
        end

        def camelize
          new(properties.map { |prop| prop.dup(name: Anchor::Types.camelize_without_inflection(prop.name)) })
        end
      end
    end

    Relationship = Struct.new(:resource, :resources, :null, :null_elements, keyword_init: true)

    class Enum
      class << self
        attr_reader :values

        def anchor_schema_name(name = nil)
          @anchor_schema_name ||= name || default_name
        end

        def value(name, value)
          @values ||= []
          @values.push([name, Types::Literal.new(value)])
        end

        private

        def default_name
          s_name = name.split("::").last
          s_name.end_with?("Enum") ? s_name.sub(/Enum\Z/, "") : s_name
        end
      end
    end

    def self.camelize_without_inflection(val)
      vals = val.split("_")
      if vals.length == 1
        vals[0]
      else
        ([vals[0]] + vals[1..].map(&:capitalize)).join("")
      end
    end

    # @param value [String, Symbol]
    # @return [String]
    def self.convert_case(value)
      case Anchor.config.field_case
      when :camel then value.to_s.underscore.camelize(:lower)
      when :camel_without_inflection then camelize_without_inflection(value.to_s.underscore)
      when :kebab then value.to_s.underscore.dasherize
      when :snake then value.to_s.underscore
      else value
      end
    end
  end
end

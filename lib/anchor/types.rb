module Anchor
  module Types
    class String; end
    class Float; end
    class Integer; end
    class BigDecimal; end
    class Boolean; end
    class Null; end
    class Unknown; end
    Record = Struct.new(:value_type)
    Maybe = Struct.new(:type)
    Array = Struct.new(:type)
    Literal = Struct.new(:value)
    Union = Struct.new(:types)
    Reference = Struct.new(:name)
    Property = Struct.new(:name, :type, :optional, :description)
    class Object
      attr_reader :properties

      def initialize(properties)
        @properties = properties
      end

      class << self
        attr_reader :properties

        def property(name, type, optional: nil, description: nil)
          @properties ||= []
          @properties.push(Property.new(name, type, optional, description))
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

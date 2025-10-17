module Anchor::Types::Inference
  module RBS
    class << self
      def enabled?
        Anchor.config.rbs.to_s == "fallback"
      end

      def validate!
        return if defined?(::RBS) && ::RBS::VERSION.first == "3"
        raise "RBS version conflict: rbs ~> 3 required."
      end

      # @param klass [Class]
      # @return [Class, nil]
      def get_definition(klass)
        env.class_decls.keys.find do |definition|
          # TODO: Do we need both absolute and relative here?
          [klass.name, "::#{klass.name}"].include?(definition.to_s)
        end
      end

      def build_instance(klass)
        if (definition = get_definition(klass))
          builder.build_instance(definition)
        end
      end

      def from_rbs_type(type)
        case type
        when ::RBS::Types::ClassInstance then from_class_instance(type)
        when ::RBS::Types::Literal then Types::Literal.new(type.literal)
        when ::RBS::Types::Bases::Bool then Types::Boolean
        when ::RBS::Types::Bases::Nil then Types::Null
        when ::RBS::Types::Bases::Void then Types::Unknown
        when ::RBS::Types::Bases::Any then Types::Unknown
        when ::RBS::Types::Optional then Types::Maybe.new(from_rbs_type(type.type))
        when ::RBS::Types::Record then from_record(type)
        when ::RBS::Types::Union then from_union(type)
        when ::RBS::Types::Intersection then from_intersection(type)
        when ::RBS::Types::Tuple then Types::Unknown # TODO
        else Types::Unknown
        end
      end

      private

      def builder
        @builder ||= ::RBS::DefinitionBuilder.new(env:)
      end

      def env
        @env ||= ::RBS::Environment.from_loader(loader).resolve_type_names
      end

      def loader
        @loader ||= ::RBS::EnvironmentLoader.new.tap do |l|
          l.add(path: Anchor.config.rbs_sig_path)
        end
      end

      def from_record(type)
        properties = type.fields.map do |name, type|
          Types::Property.new(name, from_rbs_type(type))
        end
        optional_properties = type.optional_fields.map do |name, type|
          Types::Property.new(name, from_rbs_type(type), true)
        end
        Types::Object.new(properties + optional_properties)
      end

      def from_union(type)
        types = type.types.map { |type| from_rbs_type(type) }
        Types::Union.new(types)
      end

      def from_intersection(type)
        types = type.types.map { |type| from_rbs_type(type) }
        Types::Intersection.new(types)
      end

      def from_class_instance(type)
        case type.name.to_s
        when "::String" then Types::String
        when "::Numeric" then Types::Float
        when "::Integer" then Types::Integer
        when "::Float" then Types::Float
        when "::BigDecimal" then Types::String
        when "::Boolean" then Types::Boolean
        when "::Array" then Types::Array.new(from_rbs_type(type.args.first))
        else Types::Unknown
        end
      end
    end
  end
end

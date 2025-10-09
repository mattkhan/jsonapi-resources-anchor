module Anchor::Types::Inference
  module RBS
    class << self
      # @param class_name [Symbol] e.g. :Exhaustive
      # @param method_name [Symbol] e.g. :model_overridden
      def from(class_name, method_name)
        @loader ||= ::RBS::EnvironmentLoader.new.tap do |l|
          l.add(path: Rails.root.join("sig"))
        end

        @env ||= ::RBS::Environment.from_loader(@loader).resolve_type_names

        # TODO: Do we need both the absolute and non-absolute namespaces?
        klass = @env.class_decls.keys.find { |kl| [class_name.to_s, "::#{class_name}"].include?(kl.to_s) }
        return Types::Unknown unless klass

        @builder ||= ::RBS::DefinitionBuilder.new(env: @env)
        instance = @builder.build_instance(klass)

        instance_method = instance.methods[method_name]
        return Types::Unknown unless instance_method

        method_types = instance.methods[method_name].method_types
        return Types::Unknown unless method_types.length == 1

        return_type = method_types.first.type.return_type
        from_rbs_type(return_type)
      end

      private

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

module Anchor::JSONSchema
  class SchemaGenerator < Anchor::SchemaGenerator
    delegate :type_property, to: Anchor::JSONSchema::Serializer

    def initialize(register:, context: {}, include_all_fields: false, exclude_fields: nil) # rubocop:disable Lint/MissingSuper
      @register = register
      @context = context
      @include_all_fields = include_all_fields
      @exclude_fields = exclude_fields
    end

    def call
      result = {
        "$schema" => "https://json-schema.org/draft-07/schema",
        title: "Schema",
      }
      result.merge!(type_property(root_object))
      result["$defs"] = definitions
      result.to_json
    end

    private

    def resources
      @resources ||= @register.resources.map { |r| Anchor::JSONSchema::Resource.new(r) }
    end

    # @return [Anchor::Types::Object]
    def root_object
      properties = resources.map do |resource|
        Types::Property.new(resource.anchor_schema_name.underscore, Types::Reference.new(resource.anchor_schema_name))
      end

      Types::Object.new(properties)
    end

    # @return [Hash{Symbol, String => Anchor::Types}]
    def definitions
      resources.map do |resource|
        {
          resource.anchor_schema_name => type_property(resource.express(
            context: @context,
            include_all_fields: @include_all_fields,
            exclude_fields: @exclude_fields.nil? ? [] : @exclude_fields[r.anchor_schema_name.to_sym],
          )),
        }
      end.reduce(&:merge)
    end
  end
end

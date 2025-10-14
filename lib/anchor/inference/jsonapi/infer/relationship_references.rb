module Anchor::Inference::JSONAPI::Infer
  class RelationshipReferences < Base
    def infer = object(properties)

    private

    def properties
      relationships.map { |name, rel| property(name.to_s, type_for(rel)) }
    end

    def type_for(rel)
      begin
        rel.resource_klass
      rescue NameError => e
        Rails.logger.warn(e.message)
        return unknown
      end

      return reference(rel.resource_klass.anchor_schema_name) unless rel.polymorphic?

      version = nil
      version ||= rel.respond_to?(:polymorphic_types) && :new # 0.11.0.beta2
      version ||= rel.class.respond_to?(:polymorphic_types) && :old # TODO: < 0.11.0.beta2

      polymorphic_types = case version
      when :new then rel.polymorphic_types
      when :old then rel.class.polymorphic_types
      end

      return reference(rel.resource_klass.anchor_schema_name) unless polymorphic_types

      resource_klasses = polymorphic_types.map { |t| @klass.resource_klass_for(t) }
      union(resource_klasses.map { |rk| reference(rk.anchor_schema_name) })
    end

    def relationships = @klass._relationships
  end
end

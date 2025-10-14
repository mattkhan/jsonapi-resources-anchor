module Anchor::Inference::JSONAPI::Types
  class RelationshipsWrapper < Base
    include Anchor::Typeable

    def wrap(t) = t.apply_higher(wrapper_type).pick(wrapper_type.keys)

    private

    def wrapper_type
      return @wrapper_type if defined?(@wrapper_type)
      props = @klass._relationships.map do |name, rel|
        property(name.to_s, wrapper(rel), false, nil)
      end
      @wrapper_type = object(props)
    end

    def wrapper(relationship)
      case relationship
      when ::JSONAPI::Relationship::ToOne then Anchor::Types::Identity
      when ::JSONAPI::Relationship::ToMany then Anchor::Types::Array
      else raise "#{relationship.class.name} not supported"
      end
    end

    def belongs_to_type(reflection)
      reflection.options[:optional] ? Anchor::Types::Maybe : Anchor::Types::Identity
    end
  end
end

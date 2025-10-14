module Anchor::Inference::JSONAPI::Types
  class ActiveRecordRelationshipsWrapper < Base
    include Anchor::Typeable

    def initialize(klass)
      super
      @model_klass = klass._model_class
    end

    def wrap(t) = t.apply_higher(wrapper_type).pick(wrapper_type.keys)

    private

    def wrapper_type
      return @wrapper_type if defined?(@wrapper_type)

      props = @klass._relationships.filter_map do |name, rel|
        relation_name = rel.options[:relation_name]&.to_s || name.to_s

        next unless (ref = @model_klass.reflections[relation_name])

        # TODO: comments from DB?
        property(name.to_s, wrapper(ref), false, nil)
      end

      @wrapper_type = object(props)
    end

    def wrapper(reflection)
      case reflection
      when ::ActiveRecord::Reflection::BelongsToReflection then belongs_to_type(reflection)
      when ::ActiveRecord::Reflection::HasOneReflection then Anchor::Types::Maybe
      when ::ActiveRecord::Reflection::HasManyReflection then Anchor::Types::Array
      when ::ActiveRecord::Reflection::HasAndBelongsToManyReflection then Anchor::Types::Array
      when ::ActiveRecord::Reflection::ThroughReflection then wrapper(reflection.send(:delegate_reflection))
      else raise "#{reflection.class.name} not supported" # TODO: make this unknown wrapper somehow ?
      end
    end

    def belongs_to_type(reflection)
      reflection.options[:optional] ? Anchor::Types::Maybe : Anchor::Types::Identity
    end
  end
end

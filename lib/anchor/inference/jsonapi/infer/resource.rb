module Anchor::Inference::JSONAPI::Infer
  module T
    include Anchor::Inference::JSONAPI::Types
  end

  class Resource < Base
    def infer
      shell = Shell.infer(@klass)
      annotated = AnchorDef.infer(@klass)

      model = delegated_attrs(attributes) + attributes + relationships
      inferred = (model + shell).pick(shell.keys)

      fallback = rbs.pick(inferred.pick_by_value(unknown.singleton_class).keys)
      result = annotated + inferred.overwrite(fallback, keep_description: :left)

      anchor_comments.wrap(result)
    end

    private

    def attributes
      @attributes ||= overridden.wrap(active_record_model)
    end

    def relationships
      base_relationships = RelationshipReferences.infer(@klass)

      jsonapi_relationships = relationships_wrapper.wrap(base_relationships)
      active_record_relationships = active_record_relationships_wrapper.wrap(base_relationships)

      active_record_relationships + jsonapi_relationships
    end

    def rbs
      return @rbs if defined?(@rbs)
      return object([]) unless Anchor::Types::Inference::RBS.enabled?
      Anchor::Types::Inference::RBS.validate!
      @rbs = RBS.infer(@klass)
    end

    def active_record_model
      return object([]) unless @klass._model_class < ActiveRecord::Base
      Anchor::Inference::ActiveRecord::Infer::Model.infer(@klass._model_class)
    end

    def active_record_relationships_wrapper
      return T::Empty.new unless @klass._model_class < ActiveRecord::Base
      T::ActiveRecordRelationshipsWrapper.new(@klass)
    end

    def relationships_wrapper
      T::RelationshipsWrapper.new(@klass)
    end

    def overridden
      T::Overridden.new(@klass)
    end

    def anchor_comments
      T::AnchorComments.new(@klass)
    end

    def delegated_attrs(attrs)
      props = @klass._attributes.filter_map do |name, opts|
        next unless (delegate = opts[:delegate]&.to_s)
        attrs[delegate]&.dup(name: name.to_s) || property(name.to_s, unknown)
      end
      object(props)
    end
  end
end

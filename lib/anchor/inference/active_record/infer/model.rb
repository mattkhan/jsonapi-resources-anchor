# TODO: Is attribute_types.keys ⊅ columns_hash.keys possible?
# def superset?(klass) = klass.attribute_types.keys.to_set.superset?(klass.columns_hash.keys.to_set)
# !ActiveRecord::Base.descendants.reject(&:abstract_class?).all? { |k| superset?(k) }
module Anchor::Inference::ActiveRecord::Infer
  class Model < Base
    module T
      include Anchor::Inference::ActiveRecord::Types
    end

    def infer
      res = [serialized, overridden, presence_required, defaulted, column_comments].compact.reduce(columns) do |acc, elem|
        elem.wrap(acc)
      end

      res.overwrite(
        rbs.pick(
          res.pick_by_value(unknown.singleton_class).keys,
        ),
        keep_description: :left,
      )
    end

    private

    def columns
      Columns.infer(@klass).overwrite(enums, keep_description: :left)
    end

    def enums
      return object([]) unless Anchor.config.infer_ar_enums
      @enum_types ||= Enums.infer(@klass)
    end

    def column_comments
      return unless Anchor.config.use_active_record_comment
      T::ColumnComments.new(@klass)
    end

    def rbs
      return @rbs if defined?(@rbs)
      return object([]) unless Anchor::Types::Inference::RBS.enabled?
      Anchor::Types::Inference::RBS.validate!
      @rbs = RBS.infer(@klass)
    end

    def serialized
      T::Serialized.new(@klass)
    end

    def overridden
      T::Overridden.new(@klass)
    end

    def presence_required
      return unless Anchor.config.use_active_record_validations
      T::PresenceRequired.new(@klass)
    end

    def defaulted
      return unless Anchor.config.infer_default_as_non_null
      T::Defaulted.new(@klass)
    end
  end
end

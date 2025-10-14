module Anchor::Inference::JSONAPI::Types
  class AnchorComments < Base
    include Anchor::Typeable

    def wrap(t) = object(properties(t))

    private

    def properties(t)
      t.properties.map do |prop|
        prop.dup(description: comments[prop.name] || prop.description)
      end
    end

    def comments
      return @comments if defined?(@comments)
      attr_descs = @klass.try(:anchor_attributes_descriptions) || {}
      rel_descs = @klass.try(:anchor_relationships_descriptions) || {}

      @comments = attr_descs.merge(rel_descs).reject { |_, d| d.nil? }.transform_keys(&:to_s)
    end
  end
end

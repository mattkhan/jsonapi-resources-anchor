module Anchor
  module Annotatable
    extend ActiveSupport::Concern

    included do
      class << self
        attr_reader :anchor_attributes, :anchor_relationships

        # @param name [String, Symbol]
        # @param annotation_or_options [Anchor::Types, Hash, NilClass]
        # @param options [Hash]
        def attribute(name, annotation_or_options = nil, options = {})
          @anchor_attributes ||= {}
          opts = annotation_or_options.is_a?(Hash) ? annotation_or_options : options
          annotation_given = !(annotation_or_options.is_a?(Hash) || annotation_or_options.nil?)
          @anchor_attributes[name] = annotation_or_options if annotation_given
          super(name, opts)
        end

        # @param name [String, Symbol]
        # @param annotation_or_options [Anchor::Types::Relationship, Hash, NilClass]
        # @param options [Hash]
        def relationship(name, annotation_or_options = nil, options = {})
          @anchor_relationships ||= {}
          opts = annotation_or_options.is_a?(Hash) ? annotation_or_options : options
          annotation_given = !(annotation_or_options.is_a?(Hash) || annotation_or_options.nil?)
          @anchor_relationships[name] = annotation_or_options if annotation_given
          super(name, opts)
        end
      end
    end
  end
end

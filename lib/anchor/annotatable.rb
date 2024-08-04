module Anchor
  module Annotatable
    extend ActiveSupport::Concern

    included do
      def fetchable_fields
        self.class.fetchable_fields(context)
      end

      class << self
        attr_reader :anchor_attributes, :anchor_relationships, :anchor_method_added_count
        # @param name [String] The type identifier to be used in the schema.
        # @return [String]
        def anchor_schema_name(name = nil)
          @anchor_schema_name ||= name || default_anchor_schema_name
        end

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
        # @param resource_or_options [Anchor::Types::Relationship, Hash, NilClass]
        # @param options [Hash]
        def relationship(name, resource_or_options = nil, options = {})
          @anchor_relationships ||= {}
          opts = resource_or_options.is_a?(Hash) ? resource_or_options : options
          resource_given = !(resource_or_options.is_a?(Hash) || resource_or_options.nil?)
          @anchor_relationships[name] = resource_or_options if resource_given
          super(name, opts)
        end

        def fetchable_fields(context)
          fields
        end

        private

        def method_added(method_name)
          @anchor_method_added_count ||= Hash.new(0)
          @anchor_method_added_count[method_name] += 1
          super(method_name)
        end

        # inspiration from https://github.com/rmosolgo/graphql-ruby/blob/eda9b3d62b9e507787e590f0f179ec9d6956255a/lib/graphql/schema/member/base_dsl_methods.rb?plain=1#L102
        def default_anchor_schema_name
          s_name = name.split("::").last
          s_name.end_with?("Resource") ? s_name.sub(/Resource\Z/, "") : s_name
        end
      end
    end
  end
end

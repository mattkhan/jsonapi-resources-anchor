module Anchor
  module TypeInferable
    extend ActiveSupport::Concern

    included do
      class << self
        attr_reader :anchor_method_added_count

        # @param name [String] The type identifier to be used in the schema.
        # @return [String]
        def anchor_schema_name(name = nil)
          @anchor_schema_name ||= name || anchor_default_schema_name
        end

        # @param reason [String] Reason to exclude from schema.
        # @return [String]
        def anchor_exclude_from_schema(reason: nil)
          @anchor_exclude_from_schema ||= reason || (_abstract ? "Abstract." : nil)
        end

        # @return [Boolean] True if should be excluded.
        def anchor_excluded_from_schema?
          anchor_exclude_from_schema.present?
        end

        private

        # @anchor_method_added_count[attribute] > 1 implies the attribute
        # is computed via an instance method defined on the JSONAPI::Resource.
        # `JSONAPI::Resource.attribute(:name, options)` adds #name to the resource.
        # A user defined #name on the resource _also_ adds #name.
        def method_added(method_name)
          @anchor_method_added_count ||= Hash.new(0)
          @anchor_method_added_count[method_name] += 1
          super(method_name)
        end

        # inspiration from https://github.com/rmosolgo/graphql-ruby/blob/eda9b3d62b9e507787e590f0f179ec9d6956255a/lib/graphql/schema/member/base_dsl_methods.rb?plain=1#L102
        def anchor_default_schema_name
          # https://github.com/cerebris/jsonapi-resources/blob/d3c094b46a38650e583f40adc86474827b606fc7/lib/jsonapi/resource_common.rb?plain=1#L506
          # https://github.com/cerebris/jsonapi-resources/blob/d3c094b46a38650e583f40adc86474827b606fc7/lib/jsonapi/resource_common.rb?plain=1#L564
          return _type.to_s.classify if Anchor.config.use_type_as_schema_name

          s_name = name.split("::").last
          s_name.end_with?("Resource") ? s_name.sub(/Resource\Z/, "") : s_name
        end
      end
    end
  end
end

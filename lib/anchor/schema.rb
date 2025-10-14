module Anchor
  class Schema
    class DuplicateTypeError < StandardError; end

    class << self
      Register = Data.define(:resources, :enums)

      def register
        Register.new(resources: @resources || [], enums: @enums || [])
      end

      def resource(resource)
        @resources ||= []
        if @resources.map(&:anchor_schema_name).include?(resource.anchor_schema_name)
          raise DuplicateTypeError, "A resource with type name '#{resource.anchor_schema_name}' has already been registered."
        end
        @resources.push(resource)
      end

      def enum(enum)
        @enums ||= []
        @enums.push(enum)
      end
    end
  end
end

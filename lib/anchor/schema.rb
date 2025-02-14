module Anchor
  class Schema
    class << self
      Register = Struct.new(:resources, :enums, keyword_init: true)

      def register
        Register.new(resources: @resources || [], enums: @enums || [])
      end

      def resource(resource)
        @resources ||= []
        @resources.push(resource)
      end

      def enum(enum)
        @enums ||= []
        @enums.push(enum)
      end
    end
  end
end

module TSSchema
  class Schema
    class << self
      # @param resource [TSSchema::Resource]
      def resource(resource)
        @resources ||= []
        @resources.push(resource)
      end

      # @param enum [TSSchema::Types::Enum]
      def enum(enum)
        @enums ||= []
        @enums.push(enum)
      end

      # @param context [Hash]
      # @param include_all_fields [Boolean]
      # @return [String]
      def generate(context: {}, include_all_fields: true)
        maybe_type = "type Maybe<T> = T | null;"
        enums = @enums.map(&:to_ts_type_string)
        types = @resources.map { |t| t.to_ts_type_string(context:, include_all_fields:) }

        ([maybe_type] + enums + types).join("\n\n") + "\n"
      end
    end
  end
end

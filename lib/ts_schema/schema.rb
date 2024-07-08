module TSSchema
  class Schema
    class << self
      # @param resource [TSSchema::Resource]
      def resource(resource)
        @types ||= []
        @types.push(resource)
      end

      # @param enum [TSSchema::Types::Enum]
      def enum(enum)
        @types ||= []
        @types.push(enum)
      end

      # @return [String]
      def generate
        maybe_type = "type Maybe<T> = T | null;"
        types = @types.map(&:to_ts_type_string)

        ([maybe_type] + types).join("\n\n") + "\n"
      end
    end
  end
end

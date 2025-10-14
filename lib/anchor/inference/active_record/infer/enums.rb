module Anchor::Inference::ActiveRecord::Infer
  class Enums < Base
    def infer = object(properties)

    private

    def properties
      @klass.columns_hash.slice(*defined_enums.keys).merge(defined_enums) do |name, column, enum|
        property(name, column.null ? maybe(enum) : enum)
      end.values
    end

    def defined_enums
      @defined_enums ||= @klass.defined_enums.transform_values { |enum| literals(enum.values) }
    end
  end
end

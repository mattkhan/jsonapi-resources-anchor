module Anchor::Inference::ActiveRecord::Types
  class Overridden < Base
    def wrap(t) = t.untype(names)

    private

    def names
      @klass.attribute_types.keys.filter do |name|
        next unless @klass.method_defined?(name.to_sym)
        expected_generators.none? do |generator|
          @klass.instance_method(name.to_sym).owner.is_a?(generator)
        end
      end
    end

    def expected_generators
      @expected_generators ||= [
        ActiveRecord::AttributeMethods::PrimaryKey,
        ActiveRecord::AttributeMethods::GeneratedAttributeMethods,
      ]
    end
  end
end

module Anchor::Inference::ActiveRecord::Types
  class Defaulted < Base
    def wrap(t) = t.pick(names).nonnullable + t.omit(names)

    private

    def names
      @klass.columns_hash.filter_map do |name, column|
        name if has_default?(column)
      end
    end

    def has_default?(column)
      column.default.present? || column.default_function.present? && column.instance_variable_get(:@generated).blank?
    end
  end
end

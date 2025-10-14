module Anchor::Inference::ActiveRecord::Types
  class PresenceRequired < Base
    def wrap(t) = t.pick(names).nonnullable + t.omit(names)

    private

    def names
      @klass.attribute_types.keys.filter do |name|
        presence_required_for?(name)
      end
    end

    def presence_required_for?(attribute)
      @klass.validators_on(attribute).any? do |validator|
        case validator
        when ActiveRecord::Validations::NumericalityValidator then numericality_presence_required?(validator)
        when ActiveRecord::Validations::PresenceValidator then presence_required?(validator)
        else false
        end
      end
    end

    def numericality_presence_required?(validator)
      opts = validator.options.with_indifferent_access
      !(opts[:allow_nil] || opts[:if] || opts[:unless] || opts[:on])
    end

    def presence_required?(validator)
      opts = validator.options.with_indifferent_access
      !(opts[:if] || opts[:unless] || opts[:on])
    end
  end
end

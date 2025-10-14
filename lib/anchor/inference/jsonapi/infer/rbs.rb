module Anchor::Inference::JSONAPI::Infer
  class RBS < Base
    def infer = object(properties)

    private

    def properties
      included_attributes.map do |method_name|
        type = rbs.from_rbs_type(instance.methods[method_name].method_types.first.type.return_type)
        Anchor::Types::Property.new(method_name.to_s, type)
      end
    end

    def included_attributes
      instance.methods.filter_map do |method_name, method_def|
        next if method_def&.method_types&.length != 1
        method_name
      end
    end

    def instance
      return @instance if defined?(@instance)
      @instance ||= rbs.build_instance(@klass)
    end

    def rbs
      @rbs ||= Anchor::Types::Inference::RBS
    end
  end
end

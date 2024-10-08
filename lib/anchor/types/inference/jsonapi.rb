module Anchor::Types::Inference
  module JSONAPI
    class << self
      # @return [Proc{Type => Type, Anchor::Types::Array<Type>}]
      def wrapper_from_relationship(relationship)
        case relationship
        when ::JSONAPI::Relationship::ToOne then ->(type) { type }
        when ::JSONAPI::Relationship::ToMany then ->(type) { Anchor::Types::Array.new(type) }
        else raise "#{relationship.class.name} not supported"
        end
      end
    end
  end
end

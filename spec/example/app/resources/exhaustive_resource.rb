class ExhaustiveResource < ApplicationResource
  class AssertedObject < Types::Object
    property :a, Types::Literal.new("a")
    property "b-dash", Types::Literal.new(1)
    property :c, Types::Maybe.new(Types::String)
    property :d_optional, Types::Maybe.new(Types::String), optional: true
  end

  attribute :asserted_string, Types::String, description: "My asserted string."
  attribute :asserted_number, Types::Integer
  attribute :asserted_boolean, Types::Boolean
  attribute :asserted_null, Types::Null
  attribute :asserted_unknown, Types::Unknown
  attribute :asserted_object, AssertedObject
  attribute :asserted_maybe_object, Types::Maybe.new(AssertedObject)
  attribute :asserted_array_record, Types::Array.new(Types::Record.new(Types::Integer))
  attribute :asserted_union, Types::Union.new([Types::String, Types::Float])
  attribute :with_description, Types::String, description: "This is a provided description."
  attribute :inferred_unknown

  attribute :uuid
  attribute :string
  attribute :maybe_string
  attribute :text
  attribute :integer
  attribute :float
  attribute :decimal
  attribute :datetime
  attribute :timestamp
  attribute :time
  attribute :date
  attribute :boolean
  attribute :array_string
  attribute :maybe_array_string
  attribute :json
  attribute :jsonb
  attribute :daterange
  attribute :enum
  attribute :virtual_upcased_string
  attribute :loljk
  attribute :delegated_maybe_string, delegate: :maybe_string
  attribute :model_overridden
  attribute :resource_overridden
  attribute :with_comment

  class LinkSchema < Anchor::Types::Object
    property :self, Anchor::Types::String
    property :some_url, Anchor::Types::String
  end

  anchor_links_schema LinkSchema

  def asserted_string = "asserted_string"

  def asserted_number = 1

  def asserted_boolean = true

  def asserted_null = nil

  def asserted_unknown = nil

  def asserted_object = { a: "a", "b-dash" => 1, c: nil }

  def asserted_maybe_object = nil

  def asserted_array_record = [{ key: 1 }]

  def asserted_union = 2

  def inferred_unknown = nil

  def resource_overridden = "resource_overridden"

  def with_description = "with_description"
end

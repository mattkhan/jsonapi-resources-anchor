class ExhaustiveResource < TSSchema::Resource
  object = TSSchema::Types::Object.new([
    TSSchema::Types::Property.new(:a, TSSchema::Types::Literal.new("a")),
    TSSchema::Types::Property.new("b-dash", TSSchema::Types::Literal.new(1)),
    TSSchema::Types::Property.new(:c, TSSchema::Types::Maybe.new(TSSchema::Types::String)),
    TSSchema::Types::Property.new(:d_optional, TSSchema::Types::Maybe.new(TSSchema::Types::String), true),
  ])

  attribute :asserted_string, TSSchema::Types::String
  attribute :asserted_number, TSSchema::Types::Number
  attribute :asserted_boolean, TSSchema::Types::Boolean
  attribute :asserted_null, TSSchema::Types::Null
  attribute :asserted_unknown, TSSchema::Types::Unknown
  attribute :asserted_object, object
  attribute :asserted_maybe_object, TSSchema::Types::Maybe.new(object)
  attribute :asserted_array_record, TSSchema::Types::Array.new(TSSchema::Types::Record.new(TSSchema::Types::Number))
  attribute :asserted_union, TSSchema::Types::Union.new([TSSchema::Types::String, TSSchema::Types::Number])
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
end

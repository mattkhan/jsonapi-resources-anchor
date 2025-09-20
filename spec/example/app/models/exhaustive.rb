class Exhaustive < ApplicationRecord
  validates :maybe_string, presence: true

  def model_overridden = "model_overridden"

  enum :enum, { enum_sample: "sample", enum_enum: "enum", enum_value: "value" }
end

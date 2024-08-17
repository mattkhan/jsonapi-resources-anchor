class Exhaustive < ApplicationRecord
  validates :maybe_string, presence: true

  def model_overridden = "model_overridden"
end

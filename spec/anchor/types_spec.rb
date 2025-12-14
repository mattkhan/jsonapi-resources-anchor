require "rails_helper"

RSpec.describe "Types" do
  let(:string) { Anchor::Types::String }
  let(:integer) { Anchor::Types::Integer }
  let(:types) { [string, integer] }

  describe Anchor::Types::Union do
    it "can be initialized via []" do
      union = described_class[string, integer]
      expect(union.types).to eql(types)
    end
  end

  describe Anchor::Types::Intersection do
    it "can be initialized via []" do
      intersection = described_class[string, integer]
      expect(intersection.types).to eql(types)
    end
  end
end

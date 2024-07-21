module TSSchema
  class Config
    attr_accessor :ar_column_to_type, :field_case

    def initialize
      @ar_column_to_type = nil
      @field_case = nil
    end
  end
end

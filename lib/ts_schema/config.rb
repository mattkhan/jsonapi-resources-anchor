module TSSchema
  class Config
    attr_accessor :ar_column_to_type

    def initialize
      @ar_column_to_type = nil
    end
  end
end

module TSSchema
  class << self
    def config
      @config ||= TSSchema::Config.new
    end

    def configure
      yield(config)
    end
  end
end

module Anchor
  class << self
    def config
      @config ||= Anchor::Config.new
    end

    def configure
      yield(config)
    end
  end
end

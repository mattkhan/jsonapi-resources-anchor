module Anchor
  class Region
    def initialize(start_marker:, end_marker:)
      @start_marker = start_marker
      @end_marker = end_marker
    end

    def present?(text) = text.match?(regex)
    def replace(text:, content:) = text.gsub(regex) { content[regex] }
    def fence(content) = [@start_marker, content, @end_marker].join("\n")

    def regex = /#{Regexp.escape(@start_marker)}(.*?)#{Regexp.escape(@end_marker)}/m
  end
end

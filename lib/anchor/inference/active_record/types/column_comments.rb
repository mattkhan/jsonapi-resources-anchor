module Anchor::Inference::ActiveRecord::Types
  class ColumnComments < Base
    include Anchor::Typeable

    def wrap(t) = object(add_comments(t))

    private

    def add_comments(t)
      t.properties.map do |prop|
        prop.dup(description: comments[prop.name] || prop.description)
      end
    end

    def comments
      @comments ||= @klass.columns_hash.filter_map do |name, column|
        next unless column.comment
        description = serialize_comment(column.comment)
        [name, description]
      end.to_h
    end

    def serialize_comment(comment)
      return comment unless Anchor.config.ar_comment_to_string

      Anchor.config.ar_comment_to_string.call(comment)
    end
  end
end

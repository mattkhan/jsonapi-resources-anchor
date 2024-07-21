module TSSchema
  configure do |c|
    c.ar_column_to_type = lambda { |column|
      return Types::Reference.new("never") if column.name == 'loljk'
      Types::SQL.default_ar_column_to_type(column)
    }
  end
end

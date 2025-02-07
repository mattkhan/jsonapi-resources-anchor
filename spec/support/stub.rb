# rubocop:disable RSpec/RemoveConst, Security/Eval
def stub_jsonapi_resource_subclass(name, &example)
  previously_defined = Object.const_defined?(name)

  if previously_defined
    previous_klass = name.constantize
    Object.send(:remove_const, name)
  end

  klass_string = <<~EVAL
    class #{name} < JSONAPI::Resource
    end
  EVAL

  eval(klass_string)

  yield

  Object.send(:remove_const, name)
  Object.const_set(name, previous_klass) if previously_defined
end
# rubocop:enable RSpec/RemoveConst, Security/Eval

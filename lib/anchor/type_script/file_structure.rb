module Anchor::TypeScript
  class FileStructure
    # @param file_name [String] name of file, e.g. model.ts
    # @param type [Anchor::Types]
    Import = Struct.new(:file_name, :type, keyword_init: true)
    class FileUtils
      def self.imports_to_code(imports)
        imports.group_by(&:file_name).map do |file_name, file_imports|
          named_imports = file_imports.map do |import|
            import.type.try(:anchor_schema_name) || import.type.name
          end.join(",")

          "import type { #{named_imports} } from \"./#{file_name[..-4]}\";"
        end.join("\n") + "\n"
      end

      def self.def_to_code(identifier, object)
        expression = Anchor::TypeScript::Serializer.type_string(object)
        "type #{identifier} = #{expression};" + "\n"
      end

      def self.export_code(identifier)
        "export { type #{identifier} };" + "\n"
      end
    end

    def initialize(definition)
      @definition = definition
      @name = definition.name
      @object = definition.object
    end

    def name
      "#{@definition.name}.ts"
    end

    def to_code(manually_editable: false)
      imports_string = FileUtils.imports_to_code(imports)
      name = manually_editable ? "Model" : @name
      typedef = FileUtils.def_to_code(name, @object)
      export_string = FileUtils.export_code(@definition.name)

      if manually_editable
        start_autogen = "// START AUTOGEN\n"
        end_autogen = "// END AUTOGEN\n"
        unedited_export_def = "type #{@name} = Model;\n"
        [start_autogen, imports_string, typedef, end_autogen, unedited_export_def, export_string].join("\n")
      else
        [imports_string, typedef, export_string].join("\n")
      end
    end

    # @return [Array<Import>]
    def imports
      shared_imports + relationship_imports
    end

    private

    # @return [Array<Import>]
    def shared_imports
      (utils_to_import + enums_to_import).map { |type| Import.new(file_name: "shared.ts", type:) }
    end

    # @return [Array<Import>]
    def relationship_imports
      relationships_to_import
        .reject { |type| type.anchor_schema_name == @name }
        .map { |type| Import.new(file_name: "#{type.anchor_schema_name}.ts", type:) }
    end

    def relationships_to_import
      relationships = @object.properties.find { |p| p.name == :relationships }
      return [] if relationships.nil? || relationships.type.try(:properties).nil?
      relationships.type.properties.flat_map { |p| references_from_type(p.type) }.uniq.sort_by(&:anchor_schema_name)
    end

    def references_from_type(type)
      case type
      when Anchor::Types::Array, Anchor::Types::Maybe then references_from_type(type.type)
      when Anchor::Types::Union then type.types.flat_map { |t| references_from_type(t) }
      when Anchor::Types::Reference then [type]
      end.uniq.sort_by(&:anchor_schema_name)
    end

    def utils_to_import
      maybe_type = has_maybe?(@object).presence && Anchor::Types::Reference.new("Maybe")
      [maybe_type].compact
    end

    def has_maybe?(type)
      case type
      when Anchor::Types::Maybe then true
      when Anchor::Types::Array then has_maybe?(type.type)
      when Anchor::Types::Union then type.types.any? { |t| has_maybe?(t) }
      when Anchor::Types::Object, Anchor::Types::Object.singleton_class then type.properties.any? do |p|
        has_maybe?(p)
      end
      when Anchor::Types::Property then has_maybe?(type.type)
      else false
      end
    end

    def enums_to_import
      enums_to_import_from_type(@object).uniq.sort_by(&:anchor_schema_name)
    end

    def enums_to_import_from_type(type)
      case type
      when Anchor::Types::Enum.singleton_class then [type]
      when Anchor::Types::Array then enums_to_import_from_type(type.type)
      when Anchor::Types::Maybe then enums_to_import_from_type(type.type)
      when Anchor::Types::Union then type.types.flat_map { |t| enums_to_import_from_type(t) }
      when Anchor::Types::Object, Anchor::Types::Object.singleton_class then type.properties.flat_map do |p|
        enums_to_import_from_type(p)
      end
      when Anchor::Types::Property then enums_to_import_from_type(type.type)
      else []
      end
    end
  end
end

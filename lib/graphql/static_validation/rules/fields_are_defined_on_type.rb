# frozen_string_literal: true
module GraphQL
  module StaticValidation
    module FieldsAreDefinedOnType
      def on_field(node, parent)
        parent_type = @object_types[-2]
        field = context.query.types.field(parent_type, node.name)

        if field.nil?
          if parent_type.kind.union?
            add_error(GraphQL::StaticValidation::FieldsHaveAppropriateSelectionsError.new(
              "Selections can't be made directly on unions (see selections on #{parent_type.graphql_name})",
              nodes: parent,
              node_name: parent_type.graphql_name
            ))
          else
            message = "Field '#{node.name}' doesn't exist on type '#{parent_type.graphql_name}'#{context.did_you_mean_suggestion(node.name, context.warden.fields(parent_type).map(&:graphql_name))}"
            add_error(GraphQL::StaticValidation::FieldsAreDefinedOnTypeError.new(
              message,
              nodes: node,
              field: node.name,
              type: parent_type.graphql_name
            ))
          end
        else
          super
        end
      end
    end
  end
end

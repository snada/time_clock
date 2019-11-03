module Types
  class QueryType < GraphQL::Schema::Object
    field :me, Types::UserType, null: true, description: 'Currently logged in user'
    def me
      context[:current_user]
    end
  end
end

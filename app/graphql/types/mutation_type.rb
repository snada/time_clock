module Types
  class MutationType < GraphQL::Schema::Object
    field :testMutation, mutation: Mutations::TestMutation    
  end
end

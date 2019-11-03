module Types
  class UserType < GraphQL::Schema::Object
    field :username, String, null: false
    field :level, UserLevelType, null: false
  end
end

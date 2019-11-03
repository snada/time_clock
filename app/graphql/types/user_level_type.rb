module Types
  class UserLevelType < GraphQL::Schema::Enum
    value 'BASE', 'Base user', value: 'base'
    value 'ADMIN', 'Admin user', value: 'admin'
  end
end

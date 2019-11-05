module Types
  class EventType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :kind, EventKindType, null: false
    field :user, UserType, null: false
    field :stamp, GraphQL::Types::ISO8601DateTime, null: false
    field :createdAt, GraphQL::Types::ISO8601DateTime, null: false
    field :updatedAt, GraphQL::Types::ISO8601DateTime, null: false
    field :comment, String, null: true
  end
end

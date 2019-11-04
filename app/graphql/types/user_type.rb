module Types
  class UserType < GraphQL::Schema::Object
    field :username, String, null: false
    field :level, UserLevelType, null: false
    field :events, type: [EventType], null: false
    def events
      object.events.order(stamp: :desc)
    end
  end
end

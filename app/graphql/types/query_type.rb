module Types
  class QueryType < GraphQL::Schema::Object
    field :me, Types::UserType, null: true, description: 'Currently logged in user'
    def me
      context[:current_user]
    end

    field :events, [Types::EventType], null: false, description: 'Events for a specified date: default is today' do
      argument :date, GraphQL::Types::ISO8601Date, required: false
    end
    def events(**args)
      date = args[:date] || Date.current
      Event.where('stamp >= ? AND stamp <= ?', date.beginning_of_day, date.end_of_day).order(stamp: :desc)
    end
  end
end

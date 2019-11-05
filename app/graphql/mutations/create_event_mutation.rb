class Mutations::CreateEventMutation < GraphQL::Schema::Mutation
  description 'Clock in and out'

  argument :kind, Types::EventKindType, required: true
  argument :username, String, required: true
  argument :password, String, required: false
  argument :comment, String, required: false

  field :event, Types::EventType, null: false

  def resolve(args)
    user = User.find_by(username: args[:username])
    raise GraphQL::ExecutionError, 'Cannot find user' unless user

    current_user = context[:current_user]

    if (current_user && current_user.admin?) || (args[:password] && user.valid_password?(args[:password], true))
      event = Event.new(user: user, kind: args[:kind], comment: args[:comment])
      if event.save
        { event: event.reload }
      else
        raise GraphQL::ExecutionError, event.errors.full_messages.join(', ')
      end
    else
      raise GraphQL::ExecutionError, 'Password must be submitted'
    end
  end
end

class Mutations::UpdateEventMutation < GraphQL::Schema::Mutation
  description 'Clock in and out'

  argument :id, ID, required: true
  argument :comment, String, required: true

  field :event, Types::EventType, null: false

  def resolve(id:, comment:)
    current_user = context[:current_user]

    unless current_user && (current_user.admin? || current_user.event_ids.include?(id.to_i))
      raise GraphQL::ExecutionError, 'Not allowed'
    end

    event = Event.find(id)
    if event.update(comment: comment)
      { event: event }
    else
      raise GraphQL::ExecutionError, event.errors.full_messages.join(', ')
    end
  end
end

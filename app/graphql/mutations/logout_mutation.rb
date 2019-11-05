class Mutations::LogoutMutation < GraphQL::Schema::Mutation
  description 'Logout from time clock'

  field :result, GraphQL::Types::Boolean, null: false

  def resolve
    if context[:current_user_session]
      context[:current_user_session].destroy
      { result: true }
    else
      raise GraphQL::ExecutionError, 'Not allowed'
    end
  end
end

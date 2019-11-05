class Mutations::RegisterMutation < GraphQL::Schema::Mutation
  description 'This is only a test mutation, should be removed'

  argument :username, String, required: true
  argument :password, String, required: true
  argument :passwordConfirmation, String, required: true

  field :user, Types::UserType, null: false

  def resolve(args)
    if !context[:current_user] || context[:current_user].admin?
      user = User.create(args)
      if user.valid?
        { user: user }  
      else
        raise GraphQL::ExecutionError, user.errors.full_messages.join(', ')
      end
    else
      raise GraphQL::ExecutionError, 'Not allowed'
    end
  end
end

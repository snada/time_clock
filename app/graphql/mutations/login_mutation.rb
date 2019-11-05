class Mutations::LoginMutation < GraphQL::Schema::Mutation
  description 'Login to time clock'

  argument :username, String, required: true
  argument :password, String, required: true

  field :user, Types::UserType, null: false

  def resolve(username:, password:)
    unless context[:current_user_session]
      @user_session = UserSession.create({
        username: username,
        password: password
      })
      if @user_session.valid?
        { user: @user_session.user }
      else
        raise GraphQL::ExecutionError, 'Invalid login'
      end
    else
      raise GraphQL::ExecutionError, 'Not allowed'
    end
  end
end

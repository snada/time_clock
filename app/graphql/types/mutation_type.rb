module Types
  class MutationType < GraphQL::Schema::Object
    field :registerMutation, mutation: Mutations::RegisterMutation
    field :loginMutation, mutation: Mutations::LoginMutation
    field :logoutMutation, mutation: Mutations::LogoutMutation
    field :createEventMutation, mutation: Mutations::CreateEventMutation
    field :updateEventMutation, mutation: Mutations::UpdateEventMutation
  end
end

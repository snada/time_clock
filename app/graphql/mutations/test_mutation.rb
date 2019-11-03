class Mutations::TestMutation < GraphQL::Schema::Mutation
  description 'This is only a test mutation, should be removed'

  argument :input, String, required: true

  field :output, String, null: false

  def resolve(input:)
    { output: input }
  end
end

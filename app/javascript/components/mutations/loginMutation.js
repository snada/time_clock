import gql from 'graphql-tag';

export default gql`
  mutation login($username: String!, $password: String!) {
    loginMutation(username: $username, password: $password) {
      user {
        username
        level
        events {
          id
          kind
          comment
        }
      }
    }
  }
`;

import gql from 'graphql-tag';

export default gql`
  mutation register($username: String!, $password: String!, $passwordConfirmation: String!) {
    registerMutation(username: $username, password: $password, passwordConfirmation: $passwordConfirmation) {
      user {
        username
      }
    }
  }
`;


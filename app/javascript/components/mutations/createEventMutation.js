import gql from 'graphql-tag';

export default gql`
  mutation createEvent($username: String!, $password: String, $kind: EventKind!, $comment: String) {
    createEventMutation(username: $username, password: $password, kind: $kind, comment: $comment) {
      event {
        id
        kind
        comment
        stamp
      }
    }
  }
`;

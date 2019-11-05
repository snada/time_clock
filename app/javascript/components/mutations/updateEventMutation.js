import gql from 'graphql-tag';

export default gql`
  mutation updateEvent($id: ID!, $comment: String!) {
    updateEventMutation(id: $id, comment: $comment) {
      event {
        id
        comment
      }
    }
  }
`;

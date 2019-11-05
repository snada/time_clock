import gql from 'graphql-tag';

export default gql`
  query me {
    me {
      username
      level
      events {
        id
        comment
        kind
      }
    }
  }
`;

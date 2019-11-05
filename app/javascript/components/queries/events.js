import gql from 'graphql-tag';

export default gql`
  query events($date: ISO8601Date) {
    events(date: $date) {
      id
      kind
      comment
      stamp
      user {
        username
      }
    }
  }
`;

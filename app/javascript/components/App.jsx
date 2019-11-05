import React from 'react';

import 'react-dates/initialize';

import { ApolloProvider } from '@apollo/react-hooks';
import ApolloClient from 'apollo-client';
import { Query } from 'react-apollo';
import { HttpLink } from 'apollo-link-http';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { ApolloLink, concat } from 'apollo-link';

import Dashboard from './Dashboard';

const httpLink = new HttpLink({
  uri: '/graphql',
  credentials: 'same-origin'
});
const authMiddleware = new ApolloLink((operation, forward) => {
  operation.setContext({
    headers: {
      'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').getAttribute('content'),
    },
  });
  return forward(operation);
});
const client = new ApolloClient({
  link: concat(authMiddleware, httpLink),
  cache: new InMemoryCache(),
});

import ME from './queries/me';

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      user: null
    };

    this.setUser = this.setUser.bind(this);
  }

  setUser(user) {
    this.setState({ user });
  }

  render () {
    return (
      <ApolloProvider client={client}>
        <Query
          fetchPolicy="network-only"
          query={ME}
          onCompleted={data => {
            this.setState({ user: data.me })
          }}
        >
          {({ refetch }) => (
            <Dashboard user={this.state.user} setUser={user => this.setUser(user)} reloadUser={() => refetch()} />
          )}
        </Query>
      </ApolloProvider>
    );
  }
}

export default App;

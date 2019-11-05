
import React from 'react';
import Table from 'react-bootstrap/Table';

import Event from './Event';

export default (props) => (
  <Table striped bordered hover>
    <thead>
      <tr>
        <th>Username</th>
        <th>Type</th>
        <th>Time</th>
        <th>Comment</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
    {
      props.events && (props.events.map(event => <Event key={event.id} event={event} {...props} />))
    }
    </tbody>
  </Table>
);

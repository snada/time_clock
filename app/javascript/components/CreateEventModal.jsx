import React, { useState } from 'react';

import Alert from 'react-bootstrap/Alert';
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';
import Form from 'react-bootstrap/Form';

import moment from 'moment';

import { useMutation } from '@apollo/react-hooks';
import CREATE from './mutations/createEventMutation';

const defaultInfo = { username: '', comment: '', password: '' };

export default props => {
  const [info, setInfo] = useState(defaultInfo);
  const [errors, setErrors] = useState(null);
  const [createMutation] = useMutation(CREATE);

  return(
    <Modal
      show={props.show}
      onHide={() => {
        setInfo(defaultInfo);
        setErrors(null);
        props.onHide();
      }}
      size="lg"
      centered
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-vcenter">
          {props.kind === 'CLOCK_IN' ? 'Clock in' : 'Clock out' }
        </Modal.Title>
      </Modal.Header>
      <Modal.Body>
        {
          errors ? (
            <Alert variant="danger" dismissible onClose={() => setErrors(null)}>
              <ul>
                {errors.map(error => <li key={moment().valueOf()}>{error.message}</li>)}
              </ul>
            </Alert>
          ) : null
        }
        <Form>
          <Form.Group>
            <Form.Label>Username</Form.Label>
            <Form.Control
              placeholder="Enter username"
              value={info.username}
              onChange={(e) => setInfo({ ...info, username: e.target.value })}
            />
          </Form.Group>
          {
            (!props.user || props.user.level !== 'ADMIN') ? (
              <Form.Group>
                <Form.Label>Password</Form.Label>
                <Form.Control
                  type="password"
                  placeholder="Enter password"
                  value={info.password}
                  onChange={(e) => setInfo({ ...info, password: e.target.value })}
                />
              </Form.Group>
            ) : null
          }
          <Form.Group>
            <Form.Label>Comment</Form.Label>
            <Form.Control
              placeholder="Enter comment (optional)"
              value={info.comment}
              onChange={(e) => setInfo({ ...info, comment: e.target.value })}
            />
          </Form.Group>
          <Button variant="primary" type="submit" onClick={(e) => {
            e.preventDefault();
            createMutation({ variables: { ...info, kind: props.kind } }).then(
              (result) => {
                props.onHide();
                props.onCreate(result.data.createEventMutation.event);
                setInfo(defaultInfo);
              },
              error => setErrors(error.graphQLErrors)
            );
          }}>
            Submit
          </Button>
        </Form>
      </Modal.Body>
    </Modal>
  )
}

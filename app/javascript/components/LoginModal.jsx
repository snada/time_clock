import React, { useState } from 'react';

import Alert from 'react-bootstrap/Alert';
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';
import Form from 'react-bootstrap/Form';

import moment from 'moment';

import { useMutation } from '@apollo/react-hooks';
import LOGIN from './mutations/loginMutation';

const defaultLogin = { username: '', password: '' };

export default props => {
  const [login, setLogin] = useState(defaultLogin);
  const [errors, setErrors] = useState(null);
  const [loginMutation] = useMutation(LOGIN);

  return(
    <Modal
      show={props.show}
      onHide={() => {
        props.onHide();
        setLogin(defaultLogin);
        setErrors(null);
      }}
      size="lg"
      centered
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-vcenter">
          Login
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
              value={login.username}
              onChange={(e) => setLogin({...login, username: e.target.value})}
            />
          </Form.Group>
          <Form.Group>
            <Form.Label>Password</Form.Label>
            <Form.Control
              type="password"
              placeholder="Password"
              value={login.password}
              onChange={(e) => setLogin({...login, password: e.target.value})}
            />
          </Form.Group>
          <Button variant="primary" type="submit" onClick={(e) => {
            e.preventDefault();
            loginMutation({ variables: login }).then(
              result => {
                setLogin(defaultLogin);
                setErrors(null);
                props.onHide();
                props.onLogin(result.data.loginMutation.user);
              },
              error => {
                setErrors(error.graphQLErrors);
              }
            );
          }}>
            Submit
          </Button>
        </Form>
      </Modal.Body>
    </Modal>
  )
};

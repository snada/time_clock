import React, { useState } from 'react';

import Alert from 'react-bootstrap/Alert';
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';
import Form from 'react-bootstrap/Form';

import moment from 'moment';

import { useMutation } from '@apollo/react-hooks';
import REGISTER from './mutations/registerMutation';

const defaultInfo = { username: '', password: '', passwordConfirmation: '' };

export default props => {
  const [info, setInfo] = useState(defaultInfo);
  const [errors, setErrors] = useState(null);
  const [registerMutation] = useMutation(REGISTER);

  return(
    <Modal
      show={props.show}
      onHide={() => {
        props.onHide();
        setInfo(defaultInfo);
        setErrors(null);
      }}
      size="lg"
      centered
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-vcenter">
          Register
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
            onChange={(e) => setInfo({...info, username: e.target.value})}
          />
        </Form.Group>
        <Form.Group>
          <Form.Label>Password</Form.Label>
          <Form.Control
            type="password"
            placeholder="Password"
            value={info.password}
            onChange={(e) => setInfo({...info, password: e.target.value})}
          />
        </Form.Group>
        <Form.Group>
          <Form.Label>Password Confirmation</Form.Label>
          <Form.Control
            type="password"
            placeholder="Password confirmation"
            value={info.passwordConfirmation}
            onChange={(e) => setInfo({...info, passwordConfirmation: e.target.value})}
          />
        </Form.Group>
        <Button variant="primary" type="submit" onClick={(e) => {
          e.preventDefault();
          registerMutation({ variables: info }).then(
            result => {
              setInfo(defaultInfo);
              props.onHide();
              setErrors(null);
              props.onRegister();
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

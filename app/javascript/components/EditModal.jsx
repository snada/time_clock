import React, { useState } from 'react';

import Alert from 'react-bootstrap/Alert';
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';
import Form from 'react-bootstrap/Form';

import moment from 'moment';

import { useMutation } from '@apollo/react-hooks';
import UPDATE from './mutations/updateEventMutation';

export default props => {
  const [comment, setComment] = useState(props.event.comment);
  const [errors, setErrors] = useState(null);
  const [updateMutation] = useMutation(UPDATE);

  return(
    <Modal
      show={props.show}
      onHide={() => {
        props.onHide();
        setComment(props.event.comment)
        setErrors(null);
      }}
      size="lg"
      centered
    >
      <Modal.Header closeButton>
        <Modal.Title id="contained-modal-title-vcenter">
          Edit event
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
            <Form.Label>Comment</Form.Label>
            <Form.Control
              placeholder="Enter comment"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
            />
          </Form.Group>
          <Button variant="primary" type="submit" onClick={(e) => {
            e.preventDefault();
            updateMutation({ variables: { id: props.event.id, comment } }).then(
              result => {
                props.onHide();
                props.onEdit();
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

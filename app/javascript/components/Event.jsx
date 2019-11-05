import React, { useState } from 'react';

import moment from 'moment';

import Tooltip from 'react-bootstrap/Tooltip';
import Button from 'react-bootstrap/Button';
import OverlayTrigger from 'react-bootstrap/OverlayTrigger';

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faComment } from '@fortawesome/free-solid-svg-icons';
import { faEdit } from '@fortawesome/free-solid-svg-icons';

import EditModal from './EditModal';

export default (props) => {
  const [editModalOpen, setEditModalOpen] = useState(false);

  return(
    <tr>
      <td>{props.event.user.username}</td>
      <td>{props.event.kind}</td>
      <td>{moment(props.event.stamp).format('MMMM Do YYYY, h:mm:ss a')}</td>
      <td>
        {
          props.event.comment ? (
            <OverlayTrigger overlay={<Tooltip>{props.event.comment}</Tooltip>}>
              <span className="d-inline-block">
                <FontAwesomeIcon icon={faComment} />
              </span>
            </OverlayTrigger>
          ) : null
        }
      </td>
      <td>
        {
          (
            props.user && (
              props.user.level === 'ADMIN' ||
              props.user.events.map(e => e.id).includes(props.event.id)
            )
          ) ? (
            <Button onClick={() => setEditModalOpen(!editModalOpen)}>
              <FontAwesomeIcon icon={faEdit} />
            </Button>
          ) : null
        }
      </td>
      <EditModal
        show={editModalOpen}
        event={props.event}
        onHide={() => setEditModalOpen(!editModalOpen)}
        onEdit={() => props.eventsRefetch()}
      />
    </tr>
  );
}

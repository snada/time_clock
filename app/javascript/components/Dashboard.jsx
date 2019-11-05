import React, { useState } from 'react';

import Alert from 'react-bootstrap/Alert';
import Button from 'react-bootstrap/Button';
import Col from 'react-bootstrap/Col';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';

import moment from 'moment';
import { DayPickerSingleDateController } from 'react-dates';

import { useQuery, useMutation } from '@apollo/react-hooks';

import LOGOUT from './mutations/logoutMutation';
import GET_EVENTS from './queries/events';

import Navigation from './Navigation';
import LoginModal from './LoginModal';
import EventList from './EventList';
import RegisterModal from './RegisterModal';
import CreateEventModal from './CreateEventModal';

export default (props) => {
  const [date, setDate] = useState(moment());
  const [errors, setErrors] = useState(null);
  const [loginModalOpen, setLoginModalOpen] = useState(false);
  const [createModalKind, setCreateModalKind] = useState(null);
  const [registerModalOpen, setRegisterModalOpen] = useState(false);

  const { data: eventsData, refetch: eventsRefetch } = useQuery(
    GET_EVENTS, {
      fetchPolicy: 'network-only',
      variables: {
        date: date.format('YYYY-MM-DD')
      }
    }
  );

  const [logoutMutation] = useMutation(LOGOUT);

  return (
    <React.Fragment>
      <Navigation
        user={props.user}
        onLoginClick={() => setLoginModalOpen(!loginModalOpen)}
        onRegisterClick={() => setRegisterModalOpen(!registerModalOpen)}
        onLogoutClick={() => logoutMutation().then(
          result => {
            if(result.data && result.data.logoutMutation.result) {
              props.setUser(null);
            }
          },
          error => setErrors(error.graphQLErrors)
        )}
      />
      <Container>
        {
          errors ? (
            <Alert id="dashboard-alert" variant="danger" dismissible onClose={() => setErrors(null)}>
              <ul>
                {errors.map(error => <li key={moment().valueOf()}>{error.message}</li>)}
              </ul>
            </Alert>
          ) : null
        }
        <Row style={{ marginTop: '12px' }}>
          <Col xs="0" />
          <Col md="12" lg="4">
            <DayPickerSingleDateController
              numberOfMonths={1}
              date={date}
              hideKeyboardShortcutsPanel
              onDateChange={newDate => setDate(newDate)}
            />
            <br />
            <div className="d-flex flex-column">
              <Button variant="success" block onClick={() => setCreateModalKind('CLOCK_IN')}>Clock in</Button>
              <Button variant="danger" block onClick={() => setCreateModalKind('CLOCK_OUT')}>Clock out</Button>
            </div>
          </Col>
          <Col md="12" lg="8">
            <EventList
              events={eventsData ? eventsData.events : []}
              eventsRefetch={eventsRefetch}
              user={props.user}
            />
          </Col>
          <Col xs="0" />
        </Row>
        <LoginModal
          show={loginModalOpen}
          onHide={() => setLoginModalOpen(!loginModalOpen)}
          onLogin={user => props.setUser(user)}
        />
        <RegisterModal
          show={registerModalOpen}
          onHide={() => setRegisterModalOpen(!registerModalOpen)}
          onRegister={() => setRegisterModalOpen(!registerModalOpen)}
        />
        <CreateEventModal
          user={props.user}
          show={createModalKind !== null}
          kind={createModalKind}
          onHide={() => setCreateModalKind(null)}
          onCreate={(event) => {
            eventsRefetch();
            setCreateModalKind(null);
            const eventDate = moment(event.stamp);
            if(eventDate != date) {
              setDate(eventDate);
            }
          }}
        />
      </Container>
    </React.Fragment>
  )
};

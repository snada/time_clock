import React from 'react';

import Navbar from 'react-bootstrap/Navbar';
import Nav from 'react-bootstrap/Nav';

export default (props) => (
  <Navbar expand="lg" variant="dark" bg="primary">
    <Navbar.Brand>
      Time clock
    </Navbar.Brand>
    <Navbar.Toggle aria-controls="basic-navbar-nav" />
    <Navbar.Collapse id="basic-navbar-nav">
      {
        props.user ? (
          <Nav>
            <Nav.Link onClick={() => props.onLogoutClick()}>
              Logout
            </Nav.Link>
          </Nav>
        ) : (
          <Nav>
            <Nav.Link onClick={() => props.onRegisterClick()}>
              Register
            </Nav.Link>
            <Nav.Link onClick={() => props.onLoginClick()}>
              Login
            </Nav.Link>
          </Nav>
        )
      }
    </Navbar.Collapse>
  </Navbar>
);

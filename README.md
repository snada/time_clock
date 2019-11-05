# Time clock

## Install

This projext is containerized, and can be run in development via docker-compose:

`docker-compose up`

This should take care of every dependency: it can take a while.

To set up the database, run:

`make db-create`

`make db-migrate`

Check the `Makefile` for a list of interesting scripts.

Simply visit `http://localhost:3000` to interact with the website.

Check out a live version at [https://timeclock.snada.it](https://timeclock.snada.it).

## Description

This is a Rails 6 backed GraphQL api, consumed by a React frontend, in single page application fashion.

It features user authentication (login, logout, registration), basic authorization (two levels of privilege).

A default admin account is provided: `admin:password`).

Anonymous users can log events as long as they provide a password. Admin users can log events on behalf of others.

Being authenticated in the system grants the possibility to edit events: non-admins can only edit their own events, admins can manage them all.

## Limitations and possible expansions

With more time, together with code linting and some heavy refactoring, rigorous feature testing would have been added, as well as proper server side rendering (by completely extracting the frontend in a separate node-based server).

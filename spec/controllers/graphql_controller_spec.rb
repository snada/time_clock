require 'rails_helper'

RSpec.describe GraphqlController, type: :controller do
  setup :activate_authlogic
  after(:each) { UserSession.find.destroy if UserSession.find }

  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, :admin) }

  context 'query' do
    describe 'me' do
      let(:query) { 'query me { me { username level }}' }

      context 'when logged out' do
        it 'returns null' do
          post :execute, params: { query: query, operationName: 'me' }
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({ data: { me: nil }})
        end
      end

      context 'when logged in' do
        before(:each) { UserSession.create(user) }

        it 'returns username and level' do
          post :execute, params: { query: query, operationName: 'me' }
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({
            data: { me: { username: user.username, level: 'BASE' }}
          })
        end

        context 'with events' do
          let(:my_events_query) { 'query me { me { events { id } }}' }

          let!(:yesterday_event) { FactoryBot.create(:event, :clock_in, user: user, stamp: Date.current - 1.day) }
          let!(:today_event) { FactoryBot.create(:event, :clock_out, user: user, stamp: Date.current) }

          it 'displays all current user events, in desc order' do
            post :execute, params: { query: my_events_query, operationName: 'me' }

            expect(JSON.parse(response.body, symbolize_names: true)).to eq({
              data: { me: { events: [{id: today_event.id.to_s}, {id: yesterday_event.id.to_s}] } }
            })
          end
        end

        context 'as admin' do
          before(:each) { UserSession.create(admin) }

          it 'returns username and level' do
            post :execute, params: { query: query, operationName: 'me' }
            expect(JSON.parse(response.body, symbolize_names: true)).to eq({
              data: { me: { username: admin.username, level: 'ADMIN' }}
            })
          end
        end
      end
    end

    describe 'events' do
      let(:user) { FactoryBot.create(:user) }

      let(:query) { 'query events($date: ISO8601Date) { events(date: $date) { id }}' }

      let!(:yesterday_event) { FactoryBot.create(:event, :clock_in, user: user, stamp: Date.current - 1.day) }
      let!(:today_event) { FactoryBot.create(:event, :clock_out, user: user, stamp: Date.current) }
      let!(:tomorrow_event) { FactoryBot.create(:event, :clock_in, user: user, stamp: Date.current + 1.day) }
      let!(:tomorrow_event2) { FactoryBot.create(:event, :clock_out, user: user, stamp: Date.current + 1.day + 1.second) }

      context 'with no date' do
        it 'returns today events' do
          post :execute, params: { query: query, operationName: 'events' }
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({
            data: { events: [{ id: today_event.id.to_s }] }
          })
        end
      end

      context 'with date' do
        it 'returns events for that date' do
          post :execute, params: { query: query, operationName: 'events', variables: { date: (Date.current - 1.day).to_s } }
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({
            data: { events: [{ id: yesterday_event.id.to_s }] }
          })
        end
      end

      context 'order' do
        it 'is desc' do
          post :execute, params: { query: query, operationName: 'events', variables: { date: (Date.current + 1.day).to_s } }
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({
            data: { events: [{ id: tomorrow_event2.id.to_s }, { id: tomorrow_event.id.to_s }] }
          })
        end
      end
    end
  end

  context 'mutations' do
    describe 'createEvent' do
      let(:query) {
        'mutation createEvent($username: String!, $password: String, $kind: EventKind!, $comment: String) {
          createEventMutation(username: $username, password: $password, kind: $kind, comment: $comment) {
            event {
              id
              kind
              comment
              stamp
            }
          }
        }'
      }

      context 'when logged out' do
        context 'with invalid password' do
          it 'does not create the event' do
            expect{
              post :execute, params: { query: query, operationName: 'createEvent', variables: {
                username: user.username,
                password: "wrong",
                kind: 'CLOCK_IN',
                comment: 'a comment'
              }}
            }.not_to change{ user.events.count }
          end
        end

        context 'with invalid data' do
          before(:each) { FactoryBot.create(:event, :clock_in, user: user) }

          it 'does not create the event' do
            expect{
              post :execute, params: { query: query, operationName: 'createEvent', variables: {
                username: user.username,
                password: "password",
                kind: 'CLOCK_IN',
                comment: 'a comment'
              }}
            }.not_to change{ user.events.count }
          end
        end

        context 'with valid data' do
          it 'creates the event' do
            expect{
              post :execute, params: { query: query, operationName: 'createEvent', variables: {
                username: user.username,
                password: "password",
                kind: 'CLOCK_IN',
                comment: 'a comment'
              }}
            }.to change{ user.events.count }.by(1)
          end

          it 'should return the event' do
            post :execute, params: { query: query, operationName: 'createEvent', variables: {
              username: user.username,
              password: "password",
              kind: 'CLOCK_IN',
              comment: 'a comment'
            }}
            expect(JSON.parse(response.body, symbolize_names: true).dig(:data, :createEventMutation, :event)).to include({
              comment: 'a comment',
              kind: 'CLOCK_IN'
            })
          end
        end
      end
    end

    describe 'updateEvent' do
      let(:event) { FactoryBot.create(:event, :clock_in, user: user, comment: 'old comment') }

      let(:query) {
        'mutation updateEvent($id: ID!, $comment: String!) {
          updateEventMutation(id: $id, comment: $comment) {
            event {
              id
              kind
              comment
              stamp
            }
          }
        }'
      }

      context 'when logged in as owner' do
        before(:each) { UserSession.create(user) }

        it 'updates the event' do
          expect{
            post :execute, params: { query: query, operationName: 'updateEvent', variables: {
              id: event.id,
              comment: 'new comment'
            }}
          }.to change{ event.reload.comment }.from('old comment').to('new comment')
        end

        it 'does not update the event on bad data' do
          expect{
            post :execute, params: { query: query, operationName: 'updateEvent', variables: {
              id: event.id,
              comment: 'a' * 101
            }}
          }.not_to change{ event.reload.comment }
        end
      end

      context 'when logged in as admin' do
        before(:each) { UserSession.create(admin) }

        it 'updates the event' do
          expect{
            post :execute, params: { query: query, operationName: 'updateEvent', variables: {
              id: event.id,
              comment: 'new comment'
            }}
          }.to change{ event.reload.comment }.from('old comment').to('new comment')
        end
      end

      context 'when logged in as another user' do
        let(:another_user) { FactoryBot.create(:user) }

        before(:each) { UserSession.create(another_user) }

        it 'is not allowed' do
          expect{
            post :execute, params: { query: query, operationName: 'updateEvent', variables: {
              id: event.id,
              comment: 'new comment'
            }}
          }.not_to change{ event.reload.comment }
        end
      end
    end

    describe 'login' do
      let(:query) { 'mutation login($username: String!, $password: String!) {
        loginMutation(username: $username, password: $password) {
          user {
            username
            level
          }
        }
      }' }

      context 'when logged in' do
        before(:each) { UserSession.create(user) }

        it 'is not allowed' do
          post :execute, params: { query: query, operationName: 'login', variables: {
            username: user.username,
            password: "password"
          }}
          expect(JSON.parse(response.body, symbolize_names: true)[:errors].first[:message]).to eq('Not allowed')
        end
      end

      context 'when logged out' do
        context 'with valid data' do
          it 'returns users attributes' do
            post :execute, params: { query: query, operationName: 'login', variables: {
              username: user.username,
              password: "password"
            }}
            expect(JSON.parse(response.body, symbolize_names: true)).to eq({
              data: {
                loginMutation: {
                  user: {
                    username: user.username,
                    level: 'BASE'
                  }
                }
              }
            })
          end

          it 'creates a user session' do
            expect{
              post :execute, params: { query: query, operationName: 'login', variables: {
                username: user.username,
                password: "password"
              }}
              }.to change{ UserSession.find }.from(NilClass).to(UserSession)
          end
        end

        context 'with invalid data' do
          it 'does not create a user session' do
            post :execute, params: { query: query, operationName: 'login', variables: {
              username: user.username,
              password: "wrong"
            }}
            expect(UserSession.find).to be_nil
          end
        end
      end
    end

    describe 'logout' do
      let(:query) { 'mutation logout { logoutMutation { result } }' }
      
      context 'when logged out' do
        it 'is not allowed' do
          post :execute, params: { query: query, operationName: 'logout' }
          expect(JSON.parse(response.body, symbolize_names: true)[:errors].first[:message]).to eq('Not allowed')
        end
      end

      context 'when logged in' do
        before(:each) { UserSession.create(user) }

        it 'deletes user session' do
          expect{ post :execute, params: { query: query, operationName: 'logout' } }
            .to change{ UserSession.find }.from(UserSession).to(NilClass)
        end
      end
    end

    describe 'register' do
      let(:query) { 'mutation register($username: String!, $password: String!, $passwordConfirmation: String!) {
        registerMutation(username: $username, password: $password, passwordConfirmation: $passwordConfirmation) {
          user {
            username
            level
          }
        }
      }' }

      context 'when logged out' do
        it 'is not allowed' do
          post :execute, params: { query: query, operationName: 'register', variables: {
            username: 'newuser',
            password: 'password',
            passwordConfirmation: 'password'
          }}
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({
            data: {
              registerMutation: {
                user: {
                  username: 'newuser',
                  level: 'BASE'
                }
              }
            }
          })
        end

        it 'signals error on bad data' do
          post :execute, params: { query: query, operationName: 'register', variables: {
            username: 'newuser',
            password: 'password',
            passwordConfirmation: 'bad'
          }}
          expect(
            JSON.parse(response.body, symbolize_names: true)[:data][:registerMutation]
          ).to be_nil
        end
      end

      context 'when logged in' do
        before(:each) { UserSession.create(user) }

        it 'is not allowed' do
          post :execute, params: { query: query, operationName: 'register', variables: {
            username: 'newuser',
            password: 'password',
            passwordConfirmation: 'password'
          }}
          expect(JSON.parse(response.body, symbolize_names: true)[:errors].first[:message]).to eq('Not allowed')
        end
      end

      context 'when logged in as admin' do
        before(:each) { UserSession.create(admin) }

        it 'is allowed' do
          post :execute, params: { query: query, operationName: 'register', variables: {
            username: 'newuser',
            password: 'password',
            passwordConfirmation: 'password'
          }}
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({
            data: {
              registerMutation: {
                user: {
                  username: 'newuser',
                  level: 'BASE'
                }
              }
            }
          })
        end

        it 'signals error on bad data' do
          post :execute, params: { query: query, operationName: 'register', variables: {
            username: 'newuser',
            password: 'password',
            passwordConfirmation: 'bad'
          }}
          expect(
            JSON.parse(response.body, symbolize_names: true)[:data][:registerMutation]
          ).to be_nil
        end
      end
    end
  end
end
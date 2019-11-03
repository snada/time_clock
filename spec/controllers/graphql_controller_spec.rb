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
        it 'should return null' do
          post :execute, params: { query: query, operationName: 'me' }
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({ data: { me: nil }})
        end
      end

      context 'when logged in' do
        before(:each) { UserSession.create(user) }
        it 'should return username and level' do
          post :execute, params: { query: query, operationName: 'me' }
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({
            data: { me: { username: user.username, level: 'BASE' }}
          })
        end
      end

      context 'when logged in as admin' do
        before(:each) { UserSession.create(admin) }

        it 'should return username and level' do
          post :execute, params: { query: query, operationName: 'me' }
          expect(JSON.parse(response.body, symbolize_names: true)).to eq({
            data: { me: { username: admin.username, level: 'ADMIN' }}
          })
        end
      end
    end
  end

  context 'mutations' do
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

        it 'should not be allowed' do
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
        it 'should not be allowed' do
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
        it 'should be allowed' do
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

        it 'should signal error on bad data' do
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

        it 'should not be allowed' do
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

        it 'should be allowed' do
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

        it 'should signal error on bad data' do
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
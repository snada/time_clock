class CreateUsers < ActiveRecord::Migration[6.0]
  def up
    create_table :users do |t|
      t.string    :username
      t.integer   :level, default: 0, null: false

      # Authlogic::ActsAsAuthentic::Password
      t.string    :crypted_password
      t.string    :password_salt

      # Authlogic::ActsAsAuthentic::PersistenceToken
      t.string    :persistence_token
      t.index     :persistence_token, unique: true

      # Authlogic::ActsAsAuthentic::SingleAccessToken
      t.string    :single_access_token
      t.index     :single_access_token, unique: true

      # Authlogic::ActsAsAuthentic::PerishableToken
      t.string    :perishable_token
      t.index     :perishable_token, unique: true

      # Authlogic::Session::MagicColumns
      t.integer   :login_count, default: 0, null: false
      t.integer   :failed_login_count, default: 0, null: false
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip

      t.timestamps
    end

    User.create(username: 'admin', password: 'password', password_confirmation: 'password', level: :admin)
  end

  def down
    drop_table :users
  end
end

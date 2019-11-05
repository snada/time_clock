class User < ApplicationRecord
  enum level: [:base, :admin]

  has_many :events, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :level, presence: true
  validates :password, confirmation: { if: :require_password? },
    length: {
      minimum: 8,
      if: :require_password?
    }

  validates :password_confirmation,
    length: {
      minimum: 8,
      if: :require_password?
  }

  acts_as_authentic do |c|
    c.log_in_after_create = false
    c.log_in_after_password_change = false
    c.logged_in_timeout = 7.days
  end
end

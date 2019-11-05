FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "username_#{n}" }
    password { 'password'}
    password_confirmation { 'password' }

    trait :admin do
      level { :admin }
    end
  end
end

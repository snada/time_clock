FactoryBot.define do
  factory :event do
    user
    sequence(:comment) { |n| "comment #{n}" }

    trait :clock_in do
      kind { Event::CLOCK_IN }
    end

    trait :clock_out do
      kind { Event::CLOCK_OUT }
    end
  end
end

module Types
  class EventKindType < GraphQL::Schema::Enum
    value 'CLOCK_IN', 'Clock in', value: Event::CLOCK_IN.to_s
    value 'CLOCK_OUT', 'Clock out', value: Event::CLOCK_OUT.to_s
  end
end

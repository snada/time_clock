class Event < ApplicationRecord
  CLOCK_IN = :clock_in
  CLOCK_OUT = :clock_out

  enum kind: [CLOCK_IN, CLOCK_OUT]

  belongs_to :user

  validates :kind, presence: true
  validates :stamp, uniqueness: { scope: :user_id }
  validates :comment, length: { maximum: 100 }
  validate :kind_integrity

  private
    def kind_integrity
      return unless kind

      last_event = user.events.where('stamp < ?', (stamp || DateTime.current)).last

      if clock_in? && (last_event && last_event.clock_in?)
        errors[:base] << 'You are already clocked in'
      end

      if clock_out? && (!last_event || last_event.clock_out?)
        errors[:base] << 'You can only clock out if you previously clocked in'
      end 
    end
end

require 'rails_helper'

RSpec.describe Event, type: :model do
  context 'validation' do
    it 'fails without kind' do
      expect(FactoryBot.build(:event)).not_to be_valid
    end

    it 'fails with a bad kind' do
      expect{ FactoryBot.build(:event, kind: :wrong) }.to raise_error(ArgumentError)
    end

    it 'fails with a long comment' do
      expect(FactoryBot.build(:event, :clock_in, comment: 'a' * 101)).not_to be_valid
    end

    it 'is valid without comment' do
      expect(FactoryBot.build(:event, :clock_in, comment: nil)).to be_valid
    end

    context 'stamp' do
      let(:stamp) { DateTime.current }
      let(:user)  { FactoryBot.create(:user) }
      let!(:previous_event) { FactoryBot.create(:event, :clock_in, user: user, stamp: stamp) }

      it 'fails when belonging to another event' do
        expect(user.events.new(kind: Event::CLOCK_OUT, stamp: stamp)).not_to be_valid
      end
    end

    context 'clock ins' do
      let(:user)  { FactoryBot.create(:user) }

      it 'is not valid when already clocked in' do
        FactoryBot.create(:event, :clock_in, user: user)
        expect(FactoryBot.build(:event, :clock_in, user: user)).not_to be_valid
      end
    end

    context 'clock outs' do
      let(:user)  { FactoryBot.create(:user) }

      it 'is not valid when first event for a user' do
        expect(FactoryBot.build(:event, :clock_out)).not_to be_valid
      end

      it 'is not valid when previous event already is a clock out' do
        FactoryBot.create(:event, :clock_in, user: user)
        FactoryBot.create(:event, :clock_out, user: user)
        expect(FactoryBot.build(:event, :clock_out, user: user)).not_to be_valid
      end
    end
  end
end

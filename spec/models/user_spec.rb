require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validation' do
    it 'is not valid without username' do
      expect(FactoryBot.build(:user, username: nil)).not_to be_valid
    end

    it 'is not valid with empty username' do
      expect(FactoryBot.build(:user, username: '')).not_to be_valid
    end

    it 'is not valid with a taken username' do
      FactoryBot.create(:user, username: 'taken')
      expect(FactoryBot.build(:user, username: 'taken')).not_to be_valid
    end

    it 'is not valid without password' do
      expect(FactoryBot.build(:user, password: nil)).not_to be_valid
    end

    it 'is not valid without password confirmation' do
      expect(FactoryBot.build(:user, password: 'password', password_confirmation: nil)).not_to be_valid
    end

    it 'is not valid when password_confirmation is different than password' do
      expect(FactoryBot.build(:user, password: 'password', password_confirmation: 'another')).not_to be_valid
    end

    it 'is valid when password_confirmation equals password' do
      expect(FactoryBot.build(:user, password: 'password', password_confirmation: 'password')).to be_valid
    end
  end
end

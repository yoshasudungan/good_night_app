require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  let(:user) { User.create(name: "Test User") }

  describe 'validations' do
    it 'is valid with valid attributes' do
      sleep_record = SleepRecord.new(clock_in: 1.day.ago, clock_out: Time.now, user: user)
      expect(sleep_record).to be_valid
    end

    it 'is not valid without a clock_in' do
      sleep_record = SleepRecord.new(clock_out: Time.now, user: user)
      expect(sleep_record).to_not be_valid
      expect(sleep_record.errors[:clock_in]).to include("can't be blank")
    end

    it 'is not valid without a clock_out' do
      sleep_record = SleepRecord.new(clock_in: 1.day.ago, user: user)
      expect(sleep_record).to_not be_valid
      expect(sleep_record.errors[:clock_out]).to include("can't be blank")
    end

    it 'is not valid without a user' do
      sleep_record = SleepRecord.new(clock_in: 1.day.ago, clock_out: Time.now)
      expect(sleep_record).to_not be_valid
      expect(sleep_record.errors[:user]).to include("must exist")
    end

    it 'is not valid if clock_out is before clock_in' do
      sleep_record = SleepRecord.new(clock_in: Time.now, clock_out: 1.day.ago, user: user)
      expect(sleep_record).to_not be_valid
      expect(sleep_record.errors[:clock_out].first).to include("must be greater than")
    end
  end

  describe 'callbacks' do
    it 'calculates sleep time before saving' do
      sleep_record = SleepRecord.new(clock_in: 1.day.ago, clock_out: Time.now, user: user)
      sleep_record.save
      expect(sleep_record.sleep_days).to eq(1)
      expect(sleep_record.sleep_hours).to eq(0)
      expect(sleep_record.sleep_minutes).to be_between(0, 59)
    end
  end
end
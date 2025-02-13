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
      expect(sleep_record.errors[:clock_out].first).to include("time should be greater than clock in time")
    end

    it 'is not valid if clock_in and clock_out are the same time' do
      clock_in = Time.now
      clock_out = clock_in + 0.0000001 # Adding a tiny difference
      sleep_record = SleepRecord.new(clock_in: clock_in, clock_out: clock_out, user: user)
      expect(sleep_record).to_not be_valid
      expect(sleep_record.errors[:clock_out]).to include("time should be greater than clock in time")
    end
  end

  describe 'callbacks' do
    it 'calculates sleep time before saving' do
      sleep_record = SleepRecord.new(clock_in: 1.day.ago, clock_out: Time.now, user: user)
      sleep_record.save
      expect(sleep_record.sleep_days).to eq(1)
      expect(sleep_record.sleep_hours).to eq(0)
      expect(sleep_record.sleep_minutes).to be_between(0, 59)
      expect(sleep_record.total_time).to be > 0
    end

    it 'calculates correct total sleep time (total_time) in seconds' do
      sleep_record = SleepRecord.new(clock_in: 2.days.ago, clock_out: 1.day.ago, user: user)
      sleep_record.save
      expect(sleep_record.total_time).to eq(24 * 60 * 60) # exactly one day in seconds
    end

    it 'calculates sleep time correctly for edge durations' do
      sleep_record = SleepRecord.new(clock_in: Time.now - 1.minute, clock_out: Time.now, user: user)
      sleep_record.save
      expect(sleep_record.sleep_days).to eq(0)
      expect(sleep_record.sleep_hours).to eq(0)
      expect(sleep_record.sleep_minutes).to eq(1)
      expect(sleep_record.total_time).to eq(60) # 1 minute = 60 seconds
    end

    it 'calculates multi-day sleep durations correctly' do
      sleep_record = SleepRecord.new(clock_in: 3.days.ago, clock_out: 1.day.ago, user: user)
      sleep_record.save
      expect(sleep_record.sleep_days).to eq(2)
      expect(sleep_record.sleep_hours).to eq(0)
      expect(sleep_record.sleep_minutes).to eq(0)
      expect(sleep_record.total_time).to eq(2 * 24 * 60 * 60) # exactly two days in seconds
    end
  end

  describe 'edge cases' do
    it 'calculates correct sleep duration when crossing midnight' do
      clock_in = Time.new(2025, 2, 13, 23, 30)
      clock_out = Time.new(2025, 2, 14, 1, 30)
      sleep_record = SleepRecord.new(clock_in: clock_in, clock_out: clock_out, user: user)
      sleep_record.save
      expect(sleep_record.sleep_days).to eq(0)
      expect(sleep_record.sleep_hours).to eq(2)
      expect(sleep_record.sleep_minutes).to eq(0)
    end

    it 'handles short sleep durations of less than 1 hour' do
      clock_in = Time.now - 30.minutes
      clock_out = Time.now
      sleep_record = SleepRecord.new(clock_in: clock_in, clock_out: clock_out, user: user)
      sleep_record.save
      expect(sleep_record.sleep_days).to eq(0)
      expect(sleep_record.sleep_hours).to eq(0)
      expect(sleep_record.sleep_minutes).to eq(30)
    end

    it 'handles very long sleep durations (over a week)' do
      clock_in = 8.days.ago
      clock_out = Time.now
      sleep_record = SleepRecord.new(clock_in: clock_in, clock_out: clock_out, user: user)
      sleep_record.save
      expect(sleep_record.sleep_days).to eq(8)
      expect(sleep_record.sleep_hours).to eq(0)
      expect(sleep_record.sleep_minutes).to eq(0)
    end
  end
end

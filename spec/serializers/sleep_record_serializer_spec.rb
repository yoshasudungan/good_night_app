require 'rails_helper'
require 'time'  # For Time.parse

RSpec.describe SleepRecordSerializer, type: :serializer do
  let(:user) { User.create!(name: "Test User") }
  # Fixed times for reproducibility.
  let(:clock_in)  { Time.parse("2025-02-13 00:00:00 UTC") }
  let(:clock_out) { clock_in + 8.hours }

  # For an 8-hour duration, total_minutes = 480.
  # total_time is calculated as total_minutes * 60, so 480 * 60 = 28800 seconds.
  let!(:sleep_record) do
    SleepRecord.create!(
      user: user,
      clock_in: clock_in,
      clock_out: clock_out,
      sleep_days: 0,
      sleep_hours: 8,
      sleep_minutes: 0,
      total_time: 480 * 60
    )
  end

  subject { described_class.new(sleep_record).as_json }

  it "includes the expected attributes" do
    expected_keys = %i[id clock_in clock_out sleep_time_in_seconds sleep_string user_id user_data updated_at]
    expect(subject.keys.sort).to eq(expected_keys.sort)
  end

  describe "#sleep_string" do
    it "returns the correctly formatted sleep string" do
      expect(subject[:sleep_string]).to eq("0d 8h 0m")
    end
  end

  describe "#sleep_time_in_seconds" do
    it "returns the total sleep time in seconds" do
      expect(subject[:sleep_time_in_seconds]).to eq(480 * 60)
    end
  end

  describe "#user_data" do
    it "returns the user name" do
      expect(subject[:user_data]).to eq(user.name)
    end
  end

  describe "timestamps" do
    it "includes the updated_at attribute in ISO8601 format with milliseconds" do
      expected_timestamp = sleep_record.updated_at.iso8601(3)
      expect(subject[:updated_at]).to eq(expected_timestamp)
    end
  end

  describe "other attributes" do
    it "returns the correct id" do
      expect(subject[:id]).to eq(sleep_record.id)
    end

    it "returns the correct clock_in" do
      expect(subject[:clock_in]).to eq(sleep_record.clock_in.as_json)
    end

    it "returns the correct clock_out" do
      expect(subject[:clock_out]).to eq(sleep_record.clock_out.as_json)
    end

    it "returns the correct user_id" do
      expect(subject[:user_id]).to eq(user.id)
    end
  end
end

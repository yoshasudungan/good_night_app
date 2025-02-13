require 'rails_helper'
require 'faker'
require 'time'  # For Time.parse
include ActiveSupport::Testing::TimeHelpers

RSpec.describe "SleepRecords", type: :request do
  let(:user) { User.create!(name: Faker::Name.name) }
  let(:valid_attributes) { { user_id: user.id, clock_in: Time.now, clock_out: Time.now + 8.hours } }
  let(:invalid_attributes) { { clock_in: nil, clock_out: nil } }
  let(:new_attributes) { { clock_out: Time.now + 9.hours } }

  describe "GET /index" do
    let!(:sleep_record) { SleepRecord.create!(valid_attributes) }

    context "when follower_id is provided" do
      let!(:followed_user) { User.create!(name: Faker::Name.name) }
      let!(:follow) { Follow.create!(follower_id: user.id, followed_id: followed_user.id) }

      # Create a sleep record with updated_at within the last week (should be returned)
      let!(:followed_sleep_record_in_last_week) do
        SleepRecord.create!(
          user: followed_user,
          clock_in: 5.days.ago,
          clock_out: 5.days.ago + 8.hours,
          updated_at: 5.days.ago
        )
      end

      # Create another sleep record with updated_at outside the last week (should NOT be returned)
      let!(:followed_sleep_record_outside_last_week) do
        SleepRecord.create!(
          user: followed_user,
          clock_in: 2.months.ago,
          clock_out: 2.months.ago + 8.hours,
          updated_at: 2.months.ago
        )
      end

      it "returns a successful response with sleep records for followed users" do
        get sleep_records_path, params: { follower_id: user.id }
        expect(response).to have_http_status(:success)
        records = json_response
        expect(records).not_to be_empty
        # Check that the first record's user_id matches the followed user's id
        expect(records.first["user_id"]).to eq(followed_user.id)
      end

      it "filters sleep records by updated_at in the last week" do
        # Calculate the expected range from the controller logic.
        travel_to Time.parse("2025-02-13 12:00:00 UTC") do
          start_of_last_week = Time.current.beginning_of_week(:sunday) - 1.week
          end_of_last_week   = start_of_last_week.end_of_week(:sunday)

          get sleep_records_path, params: { follower_id: user.id }
          expect(response).to have_http_status(:success)
          json_response.each do |record|
            # Ensure updated_at is present and parseable
            expect(record["updated_at"]).not_to be_nil
            updated_time = Time.parse(record["updated_at"]) rescue nil
            expect(updated_time).not_to be_nil

            # Verify that updated_time falls within the expected range.
            expect(updated_time).to be >= start_of_last_week
            expect(updated_time).to be <= end_of_last_week
          end
        end
      end

      it "caches the response for follower_id queries" do
        # Freeze time so that the computed range and cache key are predictable.
        travel_to Time.parse("2025-02-13 12:00:00 UTC") do
          Rails.cache.clear
          cache_key = "sleep_records_follower_#{user.id}_last_week"
          # Create a new sleep record within the frozen time context.
          SleepRecord.create!(
            user: followed_user,
            clock_in: 5.days.ago,
            clock_out: 5.days.ago + 8.hours,
            updated_at: 5.days.ago
          )
          get sleep_records_path, params: { follower_id: user.id }
          expect(response).to have_http_status(:success)
          cached_value = Rails.cache.read(cache_key)
          expect(cached_value).not_to be_nil
        end
      end
    end

    context "when neither user_id nor follower_id is provided" do
      it "returns an error message" do
        get sleep_records_path
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to eq("user_id or follower_id must be provided")
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new SleepRecord" do
        expect {
          post sleep_records_path, params: { sleep_record: valid_attributes }
        }.to change(SleepRecord, :count).by(1)
      end

      it "returns a created status" do
        post sleep_records_path, params: { sleep_record: valid_attributes }
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      it "does not create a new SleepRecord" do
        expect {
          post sleep_records_path, params: { sleep_record: invalid_attributes }
        }.to change(SleepRecord, :count).by(0)
      end

      it "returns an unprocessable entity status" do
        post sleep_records_path, params: { sleep_record: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /show" do
    let(:sleep_record) { SleepRecord.create!(clock_in: Time.now, clock_out: Time.now + 8.hours, user: user) }

    it "returns a successful response" do
      get sleep_record_path(sleep_record)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    let(:sleep_record) { SleepRecord.create!(clock_in: Time.current, clock_out: Time.current + 8.hours, user: user) }
    let(:new_attributes) { { clock_out: Time.current + 9.hours } }

    context "with valid parameters" do
      it "updates the requested sleep_record" do
        patch sleep_record_path(sleep_record), params: { sleep_record: new_attributes }
        sleep_record.reload
        expect(sleep_record.clock_out).to be_within(1.second).of(new_attributes[:clock_out])
      end

      it "returns a successful response" do
        patch sleep_record_path(sleep_record), params: { sleep_record: new_attributes }
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid parameters" do
      it "returns an unprocessable entity status" do
        patch sleep_record_path(sleep_record), params: { sleep_record: { clock_out: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # Helper to parse the JSON response
  def json_response
    JSON.parse(response.body)
  end
end

require 'rails_helper'
require 'faker'

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

      # Creating sleep records with updated_at values in different time ranges
      let!(:followed_sleep_record_in_last_week) do
        SleepRecord.create!(
          user_id: followed_user.id,
          clock_in: 5.days.ago,
          clock_out: 5.days.ago + 8.hours,
          updated_at: 5.days.ago
        )
      end
      let!(:followed_sleep_record_outside_last_week) do
        SleepRecord.create!(
          user_id: followed_user.id,
          clock_in: 2.months.ago,
          clock_out: 2.months.ago + 8.hours,
          updated_at: 2.months.ago
        )
      end

      it "returns a successful response with sleep records for followed users" do
        get sleep_records_path(follower_id: user.id)
        expect(response).to have_http_status(:success)

        # Ensure the response is not empty and contains user_id of followed user
        expect(json_response).not_to be_empty
        expect(json_response.first['user_id']).to eq(followed_user.id)
      end

      it "filters sleep records by updated_at in the last week" do
        get sleep_records_path(follower_id: user.id)
        expect(response).to have_http_status(:success)

        # Ensure there are no records with updated_at nil and filter by last week
        expect(json_response.any? { |record| record['updated_at'].present? && record['updated_at'] > 2.week.ago }).to be_falsey

        # Ensure no records with updated_at outside the last week are included
        expect(json_response.none? { |record| record['updated_at'].present? && record['updated_at'] < 1.week.ago }).to be_truthy
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
          post sleep_records_path, params: { sleep_record: { clock_in: nil, clock_out: nil } }
        }.to change(SleepRecord, :count).by(0)
      end

      it "returns an unprocessable entity status" do
        post sleep_records_path, params: { sleep_record: { clock_in: nil, clock_out: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /show" do
    let(:sleep_record) { SleepRecord.create!(clock_in: Time.now, clock_out: Time.now + 8.hours, user_id: user.id) }

    it "returns a successful response" do
      get sleep_record_path(sleep_record)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    let(:sleep_record) { SleepRecord.create!(clock_in: Time.current, clock_out: Time.current + 8.hours, user_id: user.id) }
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

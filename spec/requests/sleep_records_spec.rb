require 'rails_helper'
require 'faker'

RSpec.describe "SleepRecords", type: :request do
  let(:user) { User.create!(name: Faker::Name.name) }
  let(:valid_attributes) { { user_id: user.id, clock_in: Time.now, clock_out: Time.now + 8.hours } }
  let(:invalid_attributes) { { clock_in: nil, clock_out: nil } }
  let(:new_attributes) { { clock_out: Time.now + 9.hours } }

  describe "GET /index" do
    let!(:sleep_record) { SleepRecord.create!(valid_attributes) }

    context "when user_id is provided" do
      it "returns a successful response with the correct user_id" do
        get sleep_records_path(user_id: user.id)
        expect(response).to have_http_status(:success)
        # Check if the correct user_id is returned in the response
        expect(json_response.first['user_id']).to eq(user.id)
      end
    end

    context "when follower_id is provided" do
      let!(:followed_user) { User.create!(name: Faker::Name.name) }
      let!(:follow) { Follow.create!(follower_id: user.id, followed_id: followed_user.id) }
      let!(:followed_sleep_record) { SleepRecord.create!(user_id: followed_user.id, clock_in: Time.now, clock_out: Time.now + 8.hours) }

      it "returns a successful response with sleep records for followed users" do
        get sleep_records_path(follower_id: user.id)
        expect(response).to have_http_status(:success)

        # Ensure the response is not empty and contains user_id of followed user
        expect(json_response).not_to be_empty
        expect(json_response.first['user_id']).to eq(followed_user.id)
      end
    end

    context "when neither user_id nor follower_id is provided" do
      it "returns an error message" do
        get sleep_records_path
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('user_id or follower_id must be provided')
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

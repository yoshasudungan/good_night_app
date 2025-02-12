require 'rails_helper'

RSpec.describe "SleepRecords", type: :request do
  let(:user) { User.create!(name: "Test User") }
  describe "GET /index" do
    it "returns a successful response" do
      get sleep_records_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    let(:valid_attributes) { { user_id: user.id, clock_in: Time.now, clock_out: Time.now + 8.hours } }

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
    let(:sleep_record) { SleepRecord.create!(clock_in: Time.now, clock_out: Time.now + 8.hours, user_id: user.id) }
    let(:new_attributes) { { clock_out: Time.now + 9.hours } }

    context "with valid parameters" do
      it "updates the requested sleep_record" do
        patch sleep_record_path(sleep_record), params: { sleep_record: new_attributes }
        sleep_record.reload
        expect(sleep_record.clock_out).to eq(new_attributes[:clock_out])
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
end

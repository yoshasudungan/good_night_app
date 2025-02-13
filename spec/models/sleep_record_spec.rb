require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  let(:user) { User.create(name: "Test User") }

  # ... (all your existing validations, callbacks, and edge case tests remain unchanged) ...

  describe 'cache invalidation' do
    let(:follower) { User.create(name: "Follower User") }
    
    before do
      # Create a follow relationship so that the follower follows the user.
      Follow.create!(follower_id: follower.id, followed_id: user.id)
    end

    # The cache key used in the controller (and expire_cache callback) is:
    # "sleep_records_follower_#{follower.id}_last_week"
    let(:cache_key) { "sleep_records_follower_#{follower.id}_last_week" }

    context "on create" do
      it "expires the cache" do
        # Write a dummy value to the cache key.
        Rails.cache.write(cache_key, "dummy data")
        # Create a new sleep record for the user.
        SleepRecord.create!(user: user, clock_in: 1.day.ago, clock_out: Time.now)
        # After commit, the cache should have been cleared.
        expect(Rails.cache.read(cache_key)).to be_nil
      end
    end

    context "on update" do
      it "expires the cache" do
        sleep_record = SleepRecord.create!(user: user, clock_in: 1.day.ago, clock_out: Time.now)
        Rails.cache.write(cache_key, "dummy data")
        sleep_record.update(clock_out: Time.now + 1.hour)
        expect(Rails.cache.read(cache_key)).to be_nil
      end
    end

    context "on destroy" do
      it "expires the cache" do
        sleep_record = SleepRecord.create!(user: user, clock_in: 1.day.ago, clock_out: Time.now)
        Rails.cache.write(cache_key, "dummy data")
        sleep_record.destroy
        expect(Rails.cache.read(cache_key)).to be_nil
      end
    end
  end
end

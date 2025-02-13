require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'validations' do
    # Use persisted users for validation tests.
    let(:follower) { User.create!(name: "Follower User") }
    let(:followed) { User.create!(name: "Followed User") }
    let(:valid_attributes) { { follower: follower, followed: followed } }
    let(:invalid_attributes_no_follower) { { follower: nil, followed: followed } }
    let(:invalid_attributes_no_followed) { { follower: follower, followed: nil } }

    it 'is valid with valid attributes' do
      follow = Follow.new(valid_attributes)
      expect(follow).to be_valid
    end

    it 'is not valid without a follower' do
      follow = Follow.new(invalid_attributes_no_follower)
      expect(follow).to_not be_valid
      expect(follow.errors[:follower]).to include("can't be blank")
    end

    it 'is not valid without a followed' do
      follow = Follow.new(invalid_attributes_no_followed)
      expect(follow).to_not be_valid
      expect(follow.errors[:followed]).to include("can't be blank")
    end

    it 'is not valid if follower and followed are the same' do
      follow = Follow.new(follower: follower, followed: follower)
      expect(follow).to_not be_valid
      expect(follow.errors[:follower_id]).to include("can't be the same as followed id")
    end

    it 'validates uniqueness of follower_id scoped to followed_id' do
      Follow.create!(valid_attributes)
      duplicate_follow = Follow.new(valid_attributes)
      expect(duplicate_follow).to_not be_valid
      expect(duplicate_follow.errors[:follower_id]).to include("the same followed_id and follower_id already been taken")
    end
  end

  describe 'associations' do
    it 'belongs to follower' do
      assoc = Follow.reflect_on_association(:follower)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'belongs to followed' do
      assoc = Follow.reflect_on_association(:followed)
      expect(assoc.macro).to eq :belongs_to
    end
  end

  describe 'cache invalidation' do
    # Create persisted users for cache invalidation tests.
    let!(:follower) { User.create!(name: "Cache Follower") }
    let!(:followed) { User.create!(name: "Cache Followed") }
    # The cache key used in the Follow model is based on the follower's id.
    let(:cache_key) { "sleep_records_follower_#{follower.id}_last_week" }

    context "on create" do
      it "expires the cache" do
        # Write a dummy value into the cache.
        Rails.cache.write(cache_key, "dummy data")
        expect(Rails.cache.read(cache_key)).to eq("dummy data")

        # Create a new follow; after_commit should clear the cache.
        Follow.create!(follower: follower, followed: followed)
        expect(Rails.cache.read(cache_key)).to be_nil
      end
    end

    context "on destroy" do
      it "expires the cache" do
        follow = Follow.create!(follower: follower, followed: followed)
        Rails.cache.write(cache_key, "dummy data")
        expect(Rails.cache.read(cache_key)).to eq("dummy data")

        follow.destroy
        expect(Rails.cache.read(cache_key)).to be_nil
      end
    end
  end
end

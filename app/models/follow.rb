class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower, presence: true
  validates :followed, presence: true
  validate  :follower_and_followed_cannot_be_the_same
  validates :follower_id, uniqueness: { scope: :followed_id, message: "the same followed_id and follower_id already been taken" }

  # Invalidate cache after a follow is created or destroyed
  after_commit :invalidate_cache_for_follower, on: [ :create, :destroy ]

  private

  def follower_and_followed_cannot_be_the_same
    if follower_id == followed_id
      errors.add(:follower_id, "can't be the same as followed id")
    end
  end

  def invalidate_cache_for_follower
    cache_key = "sleep_records_follower_#{follower_id}_last_week"
    Rails.cache.delete(cache_key)
  end
end

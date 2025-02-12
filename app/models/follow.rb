class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower, presence: true
  validate :follower_and_followed_cannot_be_the_same
  validates :follower_id, uniqueness: { scope: :followed_id, message: "the same followed_id and follower_id already been taken" }

  private

  def follower_and_followed_cannot_be_the_same
    if follower_id == followed_id
      errors.add(:follower_id, "can't be the same as followed id")
    end
  end
  validates :followed, presence: true
end

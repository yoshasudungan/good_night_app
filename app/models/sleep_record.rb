class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :clock_in, presence: true
  validates :user, presence: true
  validates :clock_out, presence: true
  validate  :clock_out_after_clock_in

  before_save :calculate_sleep_time
  after_commit :expire_cache, on: [:create, :update, :destroy]

  private

  def clock_out_after_clock_in
    if clock_out.present? && clock_in.present? && clock_out <= clock_in
      errors.add(:clock_out, "time should be greater than clock in time")
    end
  end

  def calculate_sleep_time
    total_seconds = (clock_out - clock_in).to_i
    self.sleep_days    = total_seconds / (24 * 60 * 60)
    self.sleep_hours   = (total_seconds % (24 * 60 * 60)) / (60 * 60)
    self.sleep_minutes = (total_seconds % (60 * 60)) / 60
    self.total_time    = total_seconds
  end

  def expire_cache
    # Find all followers who follow this user
    follower_ids = Follow.where(followed_id: self.user_id).pluck(:follower_id)
    follower_ids.each do |follower_id|
      cache_key = "sleep_records_follower_#{follower_id}_last_week"
      Rails.cache.delete(cache_key)
    end
  end
end

class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :clock_in, presence: true
  validates :user, presence: true

  validates :clock_out, presence: true
  validate :clock_out_after_clock_in

  before_save :calculate_sleep_time
  private

  def clock_out_after_clock_in
    if clock_out.present? && clock_in.present? && clock_out <= clock_in
      errors.add(:clock_out, 'time should be greater than clock in time')
    end
  end

  def calculate_sleep_time
    total_minutes = ((clock_out - clock_in) / 60).to_i
    self.sleep_days = total_minutes / (24 * 60)
    self.sleep_hours = (total_minutes % (24 * 60)) / 60
    self.sleep_minutes = total_minutes % 60
    self.total_time = total_minutes * 60
  end
end

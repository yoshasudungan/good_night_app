class SleepRecord < ApplicationRecord
  belongs_to :user
  
  validates :clock_in, presence: true
  validates :user, presence: true

  validates :clock_out, presence: true, comparison: { greater_than: :clock_in }

  before_save :calculate_sleep_time

  def calculate_sleep_time
    total_minutes = (clock_out - clock_in) / 60
    self.sleep_days= (total_minutes / (24 * 60)).to_i
    self.sleep_hours= ((total_minutes % (24 * 60)) / 60).to_i
    self.sleep_minutes= (total_minutes % 60).to_i
  end
end

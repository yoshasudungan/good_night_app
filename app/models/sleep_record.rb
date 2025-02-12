class SleepRecord < ApplicationRecord
  belongs_to :user
  
  validates :clock_in, presence: true
  validates :user, presence: true
end

class SleepRecordSerializer < ActiveModel::Serializer
  attributes :id, :clock_in, :clock_out, :sleep_time_in_seconds, :sleep_string, :user_id, :user_data, :updated_at

  def sleep_string
    "#{object.sleep_days}d #{object.sleep_hours}h #{object.sleep_minutes}m"
  end

  # Since total_time is already in seconds, we return it directly.
  def sleep_time_in_seconds
    object.total_time if object.total_time.present?
  end

  def user_data
    object.user.name
  end

  def updated_at
    # Format updated_at as an ISO8601 string with 3 decimal places.
    object.updated_at.iso8601(3)
  end
end

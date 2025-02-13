# app/serializers/sleep_record_serializer.rb
class SleepRecordSerializer < ActiveModel::Serializer
  attributes :id, :clock_in, :clock_out, :sleep_time_in_seconds, :sleep_string, :user_id, :user_data, :updated_at

  def sleep_string
    "#{object.sleep_days}d #{object.sleep_hours}h #{object.sleep_minutes}m"
  end

  def sleep_time_in_seconds
    object.total_time * 60 if object.total_time.present?
  end

  def user_data
    object.user.name
  end
end

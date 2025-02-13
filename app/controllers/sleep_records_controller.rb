class SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: [ :show, :update ]

  def index
    # Initialize user_data as an empty hash to avoid nil errors later
    user_data = {}

    if params["user_id"].present?
      user_data = fetch_user_data(params[:user_id])
      @sleep_records = SleepRecord.where(user_id: params[:user_id])
                                   .order(total_time: :desc)
    elsif params["follower_id"].present?
      followed_users = fetch_followed_users(params[:follower_id])
      user_data = fetch_user_data(followed_users)

      # Filter sleep records based on updated_at range (last week)
      start_of_last_week = Time.current.beginning_of_week(:sunday) - 1.week
      end_of_last_week = start_of_last_week.end_of_week(:sunday)

      @sleep_records = SleepRecord.where(user_id: followed_users)
                                   .where(updated_at: start_of_last_week..end_of_last_week)
                                   .order(total_time: :desc)
    else
      render json: { error: "user_id or follower_id must be provided" }, status: :unprocessable_entity and return
    end

    render json: @sleep_records.map { |record| format_sleep_record(record, user_data) }
  end

  def create
    @sleep_record = SleepRecord.new(sleep_record_params)
    user_data = fetch_user_data(@sleep_record.user_id)

    if @sleep_record.save
      render json: format_sleep_record(@sleep_record, user_data), status: :created
    else
      render json: { errors: @sleep_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    unless @sleep_record
      render json: { error: "Sleep record not found" }, status: :not_found and return
    end

    user_data = fetch_user_data(@sleep_record.user_id)
    if @sleep_record.update(sleep_record_params)
      render json: format_sleep_record(@sleep_record, user_data)
    else
      render json: { errors: @sleep_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    unless @sleep_record
      render json: { error: "Sleep record not found" }, status: :not_found and return
    end

    user_data = fetch_user_data(@sleep_record.user_id)
    render json: format_sleep_record(@sleep_record, user_data)
  end

  private

  def set_sleep_record
    @sleep_record = SleepRecord.find_by(id: params[:id])
  end

  def sleep_record_params
    params.require(:sleep_record).permit(:clock_in, :clock_out, :user_id)
  end

  # Helper method to fetch user data as a hash of user_id => user_name
  def fetch_user_data(user_ids)
    user_ids = Array(user_ids) # Ensure user_ids is an array, even if it's a single id
    User.where(id: user_ids).pluck(:id, :name).to_h
  end

  # Helper method to fetch followed users' ids
  def fetch_followed_users(follower_id)
    Follow.where(follower_id: follower_id).pluck(:followed_id)
  end

  def format_sleep_record(record, user_data)
    {
      id: record.id,
      clock_in: record.clock_in,
      clock_out: record.clock_out,
      sleep_time_in_seconds: record.total_time * 60,
      sleep_string: "#{record.sleep_days}d #{record.sleep_hours}h #{record.sleep_minutes}m",
      user_id: record.user_id,
      user_data: user_data[record.user_id] # Fetch user name from user_data hash
    }
  end
end

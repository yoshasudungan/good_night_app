class SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: [ :show, :update ]

  def index
    # Initialize user_data as an empty hash to avoid nil errors later
    user_data = {}

    if params["user_id"].present?
      user_data = fetch_user_data(params[:user_id])
      @sleep_records = SleepRecord.includes(:user)  # Eager load user association
                                  .where(user_id: params[:user_id])
                                  .order(total_time: :desc)
    elsif params["follower_id"].present?
      followed_users = fetch_followed_users(params[:follower_id])
      user_data = fetch_user_data(followed_users)

      # Filter sleep records based on updated_at range (last week)
      start_of_last_week = Time.current.beginning_of_week(:sunday) - 1.week
      end_of_last_week = start_of_last_week.end_of_week(:sunday)

      cache_key = "sleep_records_follower_#{params[:follower_id]}_last_week"
      @sleep_records = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
        SleepRecord.where(user_id: followed_users)
                  .where(updated_at: start_of_last_week..end_of_last_week)
                  .order(total_time: :desc)
      end
    else
      render json: { error: "user_id or follower_id must be provided" }, status: :unprocessable_entity and return
    end

    # Render using the serializer to ensure formatted response
    render json: @sleep_records, each_serializer: SleepRecordSerializer
  end

  def create
    @sleep_record = SleepRecord.new(sleep_record_params)
    user_data = fetch_user_data(@sleep_record.user_id)

    if @sleep_record.save
      render json: @sleep_record, serializer: SleepRecordSerializer, status: :created
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
      render json: @sleep_record, serializer: SleepRecordSerializer
    else
      render json: { errors: @sleep_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    unless @sleep_record
      render json: { error: "Sleep record not found" }, status: :not_found and return
    end

    render json: @sleep_record, serializer: SleepRecordSerializer
  end

  private

  def set_sleep_record
    @sleep_record = SleepRecord.find_by(id: params[:id])
  end

  def fetch_followed_users(follower_id)
    Follow.where(follower_id: follower_id).pluck(:followed_id)
  end

  def fetch_user_data(user_ids)
    user_ids = Array(user_ids) # Ensure user_ids is an array, even if it's a single id
    User.where(id: user_ids).pluck(:id, :name).to_h
  end

  def sleep_record_params
    params.require(:sleep_record).permit(:clock_in, :clock_out, :user_id)
  end
end

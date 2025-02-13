class SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: [ :show, :update ]

  def index
    if params["user_id"].present?
      user_data = User.where(id: params[:user_id]).pluck(:id, :name).to_h
      @sleep_records = SleepRecord.where(user_id: params[:user_id]).order(total_time: :desc)
    elsif params["follower_id"].present?
      followed_users = Follow.where(follower_id: params[:follower_id]).pluck(:followed_id)
      user_data = User.where(id: followed_users).pluck(:id, :name).to_h
      @sleep_records = SleepRecord.where(user_id: followed_users).order(total_time: :desc)
    else
      # this is done like here, so that there will be no performance issues
      render json: { error: "user_id or follower_id must be provided" }, status: :unprocessable_entity and return
    end
    render json: @sleep_records.map { |record| format_sleep_record(record, user_data) }
  end

  def create
    @sleep_record = SleepRecord.new(sleep_record_params)
    user_data = User.where(id: @sleep_record.user_id).pluck(:id, :name).to_h
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

    user_data = User.where(id: @sleep_record.user_id).pluck(:id, :name).to_h
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

    user_data = User.where(id: @sleep_record.user_id).pluck(:id, :name).to_h
    render json: format_sleep_record(@sleep_record, user_data)
  end

  private

  def set_sleep_record
    @sleep_record = SleepRecord.find_by(id: params[:id])
  end

  def sleep_record_params
    params.require(:sleep_record).permit(:clock_in, :clock_out, :user_id)
  end

  def format_sleep_record(record, user_data)
    {
      id: record.id,
      clock_in: record.clock_in,
      clock_out: record.clock_out,
      sleep_time_in_seconds: record.total_time * 60,
      sleep_string: "#{record.sleep_days}d #{record.sleep_hours}h #{record.sleep_minutes}m",
      user_id: record.user_id,
      user_data: user_data[record.user_id] # Extract the user name from user_data hash based on user_id
    }
  end
end

class SleepRecordsController < ApplicationController
  def index
    if params["user_id"].present?
      @sleep_records = SleepRecord.where(user_id: params[:user_id])
    else
      @sleep_records = SleepRecord.all
    end
    render json: @sleep_records
  end

  def create
    @sleep_record = SleepRecord.new(sleep_record_params)
    if @sleep_record.save
      render json: @sleep_record, status: :created
    else
      render json: @sleep_record.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    @sleep_record = SleepRecord.find(params[:id])
    if @sleep_record.update(sleep_record_params)
      render json: @sleep_record
    else
      render json: @sleep_record.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    @sleep_record = SleepRecord.find(params[:id])
    render json: @sleep_record
  end

  private

  def sleep_record_params
    params.require(:sleep_record).permit(:clock_in, :clock_out, :user_id)
  end
end

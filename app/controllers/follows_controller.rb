class FollowsController < ApplicationController
  def create
    @follow = Follow.new(follow_params)
    if @follow.save
      render json: json_formatter(@follow), status: :created
    else
      render json: { errors: @follow.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @follow = Follow.find_by(id: params[:id])
    if @follow
      @follow.destroy
      render json: { message: 'Follow was successfully destroyed.' }, status: :ok
    else
      render json: { error: 'Follow not found' }, status: :not_found
    end
  end

  def show
    @follow = Follow.find_by(id: params[:id])
    if @follow
      render json: json_formatter(@follow), status: :ok
    else
      render json: { error: 'Follow not found' }, status: :not_found
    end
  end
  

  private

  def json_formatter(follow)
    follow.to_json(include: { follower: { only: [:id, :name] }, followed: { only: [:id, :name] }})
  end

  def follow_params
    params.require(:follow).permit(:follower_id, :followed_id)
  end
end

require 'rails_helper'

RSpec.describe FollowsController, type: :controller do
  let(:follower) { User.create(name: Faker::Name.name) }
  let(:followed) { User.create(name: Faker::Name.name) }
  let(:valid_attributes) { { follower_id: follower.id, followed_id: followed.id } }
  let(:invalid_attributes) { { follower_id: nil, followed_id: nil } }

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Follow and returns a success status' do
        expect {
          post :create, params: { follow: valid_attributes }
        }.to change(Follow, :count).by(1)

        expect(response).to have_http_status(:created)
        follow = Follow.last
        expect(response.body).to include(follow.follower.name)
        expect(response.body).to include(follow.followed.name)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Follow and returns an error status' do
        expect {
          post :create, params: { follow: invalid_attributes }
        }.to_not change(Follow, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Follower can\'t be blank')
        expect(response.body).to include('Followed can\'t be blank')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when follow exists' do
      it 'destroys the follow and returns a success status' do
        follow = Follow.create!(valid_attributes)

        expect {
          delete :destroy, params: { id: follow.id }
        }.to change(Follow, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Follow was successfully destroyed.')
      end
    end

    context 'when follow does not exist' do
      it 'returns an error status' do
        delete :destroy, params: { id: -1 }

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include('Follow not found')
      end
    end
  end

  describe 'GET #show' do
    context 'when follow exists' do
      it 'returns the follow details and a success status' do
        follow = Follow.create!(valid_attributes)

        get :show, params: { id: follow.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(follow.follower.name)
        expect(response.body).to include(follow.followed.name)
      end
    end

    context 'when follow does not exist' do
      it 'returns a not found status' do
        get :show, params: { id: -1 }

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include('Follow not found')
      end
    end
  end
end
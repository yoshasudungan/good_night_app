require 'rails_helper'

RSpec.describe 'Follows API', type: :request do
  let(:follower) { User.create(name: Faker::Name.name) }
  let(:followed) { User.create(name: Faker::Name.name) }
  let(:valid_attributes) { { follow: { follower_id: follower.id, followed_id: followed.id } } }
  let(:invalid_attributes) { { follow: { follower_id: nil, followed_id: nil } } }

  describe 'POST /follows' do
    context 'with valid params' do
      it 'creates a new Follow and returns a success status' do
        expect {
          post '/follows', params: valid_attributes
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
          post '/follows', params: invalid_attributes
        }.to_not change(Follow, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Follower can\'t be blank')
        expect(response.body).to include('Followed can\'t be blank')
      end
    end
  end

  describe 'DELETE /follows/:id' do
    context 'when follow exists' do
      it 'destroys the follow and returns a success status' do
        follow = Follow.create!(follower_id: follower.id, followed_id: followed.id)

        delete "/follows/#{follow.id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Follow was successfully destroyed.')
        expect(Follow.exists?(follow.id)).to be_falsey
      end
    end

    context 'when follow does not exist' do
      it 'returns an error status' do
        delete '/follows/999999'

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include('Follow not found')
      end
    end
  end

  describe 'GET /follows/:id' do
    context 'when follow exists' do
      it 'returns the follow details and a success status' do
        follow = Follow.create!(follower_id: follower.id, followed_id: followed.id)

        get "/follows/#{follow.id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(follow.follower.name)
        expect(response.body).to include(follow.followed.name)
      end
    end

    context 'when follow does not exist' do
      it 'returns a not found status' do
        get '/follows/999999'

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include('Follow not found')
      end
    end
  end
end

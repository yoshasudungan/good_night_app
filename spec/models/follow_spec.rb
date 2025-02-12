require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'validations' do
    let(:follower) { User.new(id: 1) }
    let(:followed) { User.new(id: 2) }
    let(:valid_attributes) { { follower: follower, followed: followed } }
    let(:invalid_attributes_no_follower) { { follower: nil, followed: followed } }
    let(:invalid_attributes_no_followed) { { follower: follower, followed: nil } }

    it 'is valid with valid attributes' do
      follow = Follow.new(valid_attributes)
      expect(follow).to be_valid
    end

    it 'is not valid without a follower' do
      follow = Follow.new(invalid_attributes_no_follower)
      expect(follow).to_not be_valid
      expect(follow.errors[:follower]).to include("can't be blank")
    end

    it 'is not valid without a followed' do
      follow = Follow.new(invalid_attributes_no_followed)
      expect(follow).to_not be_valid
      expect(follow.errors[:followed]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'belongs to follower' do
      assoc = Follow.reflect_on_association(:follower)
      expect(assoc.macro).to eq :belongs_to
    end

    it 'belongs to followed' do
      assoc = Follow.reflect_on_association(:followed)
      expect(assoc.macro).to eq :belongs_to
    end
  end
end

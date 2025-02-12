class User < ApplicationRecord
  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :followed_users, through: :follows, source: :followed
  has_many :reverse_follows, foreign_key: :followed_id, class_name: 'Follow', dependent: :destroy
end

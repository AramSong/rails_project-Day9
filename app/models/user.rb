class User < ApplicationRecord
    has_many :memberships
    has_many :daums, through: :memberships
    has_secure_password
    has_many :posts
end

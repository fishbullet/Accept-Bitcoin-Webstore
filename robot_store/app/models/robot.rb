class Robot < ApplicationRecord
  validates :title, :price, :avatar, presence: true
end

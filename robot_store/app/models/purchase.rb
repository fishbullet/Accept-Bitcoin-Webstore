class Purchase < ApplicationRecord
  validates :user_id, :robot_id, :value, presence: true
  belongs_to :user
  belongs_to :robot
end

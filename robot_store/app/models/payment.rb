class Payment < ApplicationRecord
  validates :txid, :value, :included_in_block, presence: true
  validates :txid, uniqueness: true

  belongs_to :user
end

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :payments

  has_many :purchases
  has_many :robots, through: :purchases

  def unconfirmed
    # the unconfirmed balance is the sum of unconfirmed transaction values
    payments.where(included_in_block: 0).sum(:value) / 100_000_000.0 # because values in the satoshi 0.00000001 BTC is 1 satoshi
  end

  def balance
    (confirmed - purchases.sum(:value)) / 100_000_000.0
  end

  def confirmed
    # the confirmed balance is the sum of confirmed transaction values
    payments.where('included_in_block > 0').sum(:value) # because values in the satoshi 0.00000001 BTC is 1 satoshi
  end
end

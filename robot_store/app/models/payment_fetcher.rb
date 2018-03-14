class PaymentFetcher
  def self.load!
    processor = PaymentProcessor.new
    # Need to check only users with addresses
    User.where.not(deposit_address: nil).find_each do |user|
      # Load all transactions related to the user address
      Rails.logger.warn("Load transaction for address: #{user.deposit_address}")
      processor.get_address_unspent(user.deposit_address)
      unless processor.body.any?
        next
      end
      # Check each transaction, if it's has any confirmations
      processor.body.each do |tx|
        payment = user.payments.find_by(txid: tx['tx_hash'])
        if payment
          # if any payments exists 
          # and height is not the same therefore
          # transaction was confirmed 
          if payment.included_in_block != tx['height']
            payment.update(included_in_block: tx['height'])
          end
        else
          # add payments if not exists
          user.payments.create(
            txid: tx['tx_hash'],
            value: tx['value'],
            included_in_block: tx['height']
          )
        end
      end
    end
  end
end

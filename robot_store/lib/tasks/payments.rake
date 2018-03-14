task pull_payments: :environment do
  Rails.logger.warn "Fetch payment data ..."
  PaymentFetcher.load!
  Rails.logger.warn "Payment data fetched ..."
end


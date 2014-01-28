class CoinRequest < ActiveRecord::Base
  before_validation :strip_address
  validate :validate_address
  validates_presence_of :uniqueness_token
  validates_uniqueness_of :uniqueness_token
  validate :pending_address_uniqueness

  scope :fulfilled, -> { where(fulfilled: true) }
  scope :not_fulfilled, -> { where(fulfilled: false) }
  scope :first_in_first, -> { order(:created_at) }

  def strip_address
    self.address = self.address.strip if self.address
  end

  def validate_address
    unless Peercoin.address_valid?(address)
      errors.add(:address, :invalid)
    end
  end

  def pending_address_uniqueness
    if address.present?
      others = CoinRequest.not_fulfilled.where(address: address)
      others = others.where("id != ?", id) if id
      if others.any?
        errors.add(:address, "already has another pending request")
      end
    end
  end

  def self.fulfill!
    logger.info "Started fulfill"

    requests = not_fulfilled.first_in_first

    balance = Peercoin.balance
    logger.info "Balance: #{balance}"

    amount_per_request = FaucetConfig["amount_per_request"]
    raise "No amount per request provided in config" unless amount_per_request
    logger.info "Amount per request: #{amount_per_request}"

    number_to_fulfill = (balance / amount_per_request).floor
    logger.info "Number to fulfill: #{number_to_fulfill}"

    requests = requests.limit(number_to_fulfill).to_a.select(&:valid?)
    number_to_fulfill = requests.size
    logger.info "Number to fulfill after validation: #{number_to_fulfill}"

    loop do
      if number_to_fulfill < 1
        logger.info "No request remaining. Aborting"
        break
      end

      requests = requests[0, number_to_fulfill]
      logger.info "Requests selected: #{requests.inspect}"

      recipients = requests.map { |request| [request.address, amount_per_request] }.to_h
      logger.info "Sending #{recipients.inspect}"

      begin
        Peercoin.send_many(recipients)
        logger.info "Marking as fulfilled"
        requests.each do |request|
          request.update_attribute(:fulfilled, true)
        end

        logger.info "Fulfill done"
        break

      rescue Peercoin::InsufficientFunds
        logger.info "Not enought funds. Removing a request"
        number_to_fulfill -= 1
      end
    end
  end
end

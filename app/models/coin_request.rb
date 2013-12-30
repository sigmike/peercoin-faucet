class CoinRequest < ActiveRecord::Base
  validate :validate_address

  def validate_address
    unless Peercoin.address_valid?(address)
      errors.add(:address, :invalid)
    end
  end
end

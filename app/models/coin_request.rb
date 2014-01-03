class CoinRequest < ActiveRecord::Base
  validate :validate_address
  validates_presence_of :uniqueness_token
  validates_uniqueness_of :uniqueness_token

  def validate_address
    unless Peercoin.address_valid?(address)
      errors.add(:address, :invalid)
    end
  end
end

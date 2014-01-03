class CoinRequest < ActiveRecord::Base
  validate :validate_address
  validates_presence_of :ip
  validate :validate_delay

  def validate_address
    unless Peercoin.address_valid?(address)
      errors.add(:address, :invalid)
    end
  end

  def validate_delay
    others = CoinRequest.where(ip: ip)
    others = others.where('id != ?', id) if id
    date_end = (created_at || Time.now)
    date_start = date_end - 1.day
    others = others.where('created_at > ? AND created_at <= ?', date_start, date_end)
    if others.count != 0
      errors.add(:base, "You already have a recent request")
    end
  end
end

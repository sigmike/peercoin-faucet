class State < ActiveRecord::Base
  serialize :last_transactions

  def self.instance
    first_or_initialize
  end

  def self.update!
    state = instance
    state.address = Peercoin.address
    state.balance = Peercoin.balance
    state.last_transactions = Peercoin.transactions
    state.save!
  end
end

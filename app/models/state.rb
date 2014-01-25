class State < ActiveRecord::Base
  serialize :last_transactions
  serialize :info

  def self.instance
    first_or_initialize
  end

  def self.update!
    state = instance
    state.address = Peercoin.address
    state.balance = Peercoin.balance
    state.last_transactions = Peercoin.transactions
    state.info = Peercoin.info
    state.save!
  end

  def testnet?
    info["testnet"]
  end

  def empty?
    balance <= FaucetConfig["amount_per_request"]
  end
end

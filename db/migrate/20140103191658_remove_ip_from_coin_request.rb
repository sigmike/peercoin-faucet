class RemoveIpFromCoinRequest < ActiveRecord::Migration
  def change
    remove_column :coin_requests, :ip, :string
  end
end

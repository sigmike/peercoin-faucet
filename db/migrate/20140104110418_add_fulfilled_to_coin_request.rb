class AddFulfilledToCoinRequest < ActiveRecord::Migration
  def change
    add_column :coin_requests, :fulfilled, :boolean, default: false
  end
end

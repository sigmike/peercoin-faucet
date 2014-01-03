class AddUniquenessTokenToCoinRequest < ActiveRecord::Migration
  def change
    add_column :coin_requests, :uniqueness_token, :string, uniq: true
  end
end

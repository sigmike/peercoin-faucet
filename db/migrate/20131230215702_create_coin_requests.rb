class CreateCoinRequests < ActiveRecord::Migration
  def change
    create_table :coin_requests do |t|
      t.string :address
      t.string :ip
      t.boolean :processed, default: false

      t.timestamps
    end
  end
end

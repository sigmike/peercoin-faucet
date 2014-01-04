class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :address
      t.float :balance
      t.text :last_transactions

      t.timestamps
    end
  end
end

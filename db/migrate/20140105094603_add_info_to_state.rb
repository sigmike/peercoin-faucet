class AddInfoToState < ActiveRecord::Migration
  def change
    add_column :states, :info, :string, limit: 1024
  end
end

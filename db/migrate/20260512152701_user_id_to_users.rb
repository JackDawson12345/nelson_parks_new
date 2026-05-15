class UserIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :xero_id, :string
  end
end

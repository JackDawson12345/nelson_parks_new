class AddDataToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :full_name, :text
    add_column :users, :phone_number, :text
  end
end

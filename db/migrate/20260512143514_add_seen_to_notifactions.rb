class AddSeenToNotifactions < ActiveRecord::Migration[7.2]
  def change
    add_column :notifications, :seen, :boolean, default: false
  end
end

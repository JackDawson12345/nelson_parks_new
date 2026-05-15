class LatePaymentChanges < ActiveRecord::Migration[7.2]
  def change
    remove_column :late_payments, :frequency
    remove_column :late_payments, :year

    add_column :late_payments, :due_date, :date
  end
end

class ChangeDueDateToDatetimeInInvoices < ActiveRecord::Migration[7.2]
  def change
    change_column :invoices, :due_date, :datetime
  end
end

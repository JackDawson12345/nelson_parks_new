class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pitch, null: false, foreign_key: true
      t.string :invoice_id
      t.string :status
      t.decimal :total
      t.decimal :amount_due
      t.decimal :amount_paid
      t.date :due_date

      t.timestamps
    end
  end
end

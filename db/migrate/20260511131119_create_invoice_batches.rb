class CreateInvoiceBatches < ActiveRecord::Migration[7.2]
  def change
    create_table :invoice_batches do |t|
      t.references :park, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.date :invoice_date
      t.date :due_date
      t.text :notes
      t.json :reading

      t.timestamps
    end
  end
end

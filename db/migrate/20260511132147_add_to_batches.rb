class AddToBatches < ActiveRecord::Migration[7.2]
  def change
    add_column :invoice_batches, :reference, :string
    add_column :invoice_batches, :status, :string
  end
end

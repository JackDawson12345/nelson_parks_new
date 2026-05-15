class AddReferenceToInvoice < ActiveRecord::Migration[7.2]
  def change
    add_column :invoices, :reference, :string
  end
end

class AddUtilityToInviceBatches < ActiveRecord::Migration[7.2]
  def change
    add_column :invoice_batches, :utility, :string
  end
end

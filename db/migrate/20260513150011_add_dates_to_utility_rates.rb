class AddDatesToUtilityRates < ActiveRecord::Migration[7.2]
  def change
    add_column :utility_rates, :from_date, :date
    add_column :utility_rates, :to_date, :date
  end
end

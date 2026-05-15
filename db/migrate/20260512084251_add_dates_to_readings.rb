class AddDatesToReadings < ActiveRecord::Migration[7.2]
  def change
    add_column :meter_readings, :start_date, :date
    add_column :meter_readings, :end_date, :date
  end
end

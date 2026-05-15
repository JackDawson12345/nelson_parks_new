class CreateMeterReadings < ActiveRecord::Migration[7.2]
  def change
    create_table :meter_readings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pitch, null: false, foreign_key: true
      t.string :utility
      t.decimal :opening_reading
      t.decimal :closing_reading
      t.decimal :consumption
      t.text :notes

      t.timestamps
    end
  end
end

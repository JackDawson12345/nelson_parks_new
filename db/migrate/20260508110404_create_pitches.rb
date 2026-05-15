class CreatePitches < ActiveRecord::Migration[7.2]
  def change
    create_table :pitches do |t|
      t.string :pitch_number
      t.references :park, null: false, foreign_key: true
      t.string :pitch_type
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

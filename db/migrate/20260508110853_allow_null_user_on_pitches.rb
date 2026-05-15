class AllowNullUserOnPitches < ActiveRecord::Migration[7.2]
  def change
    change_column_null :pitches, :user_id, true
  end
end

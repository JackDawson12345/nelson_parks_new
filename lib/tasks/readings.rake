namespace :readings do
  desc "Create monthly meter readings"

  task monthly_create: :environment do
    period_start = Time.current.last_month.change(day: 8).beginning_of_day
    period_end   = Time.current.change(day: 8).end_of_day

    User.joins(:pitch).find_each do |user|
      pitch = user.pitch

      ['Electric', 'Gas'].each do |utility|
        # Skip gas readings for parks 6 and 7
        next if utility == 'Gas' && [6, 7].include?(pitch.park_id)

        next if MeterReading.exists?(
          user_id: user.id,
          utility: utility,
          start_date: period_start,
          end_date: period_end
        )

        previous_reading = MeterReading
                             .where(user_id: user.id, utility: utility)
                             .order(end_date: :desc)
                             .first

        opening_value = previous_reading&.closing_reading || 0

        MeterReading.create!(
          user_id: user.id,
          pitch_id: pitch.id,
          utility: utility,
          start_date: period_start,
          end_date: period_end,
          opening_reading: opening_value,
          closing_reading: opening_value,
          consumption: 0.0,
          notes: ''
        )
      end
    end
  end
end
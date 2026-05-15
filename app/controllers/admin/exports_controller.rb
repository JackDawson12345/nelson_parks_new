class Admin::ExportsController < Admin::BaseController
  require 'csv'

  def index
    @parks = Park.all
  end

  def clients_export
    # Preload associated data to avoid N+1 queries (pitch and park)
    clients = User.where(admin: false).includes(pitch: :park)

    # Fetch total_due data with a single query (avoiding repeated queries)
    invoice_totals = Invoice.where(user_id: clients.pluck(:id)).group(:user_id).sum(:amount_due)

    # Create the CSV data
    csv_data = CSV.generate(headers: true) do |csv|
      # Add headers for CSV
      csv << ["ID", "Name", "Email", "Phone Number", "Park Name", "Pitch Number", "Balance Due"]

      # Iterate over clients and write to CSV
      clients.find_each do |client|
        # Retrieve the total due from the precomputed invoice totals
        total_due = invoice_totals[client.id] || 0

        # Write client data to CSV
        csv << [
          client.id,
          client.full_name,
          client.email,
          client.phone_number,
          client.pitch&.park&.name, # Handle possible nil if pitch/park is missing
          client.pitch&.pitch_number,
          total_due
        ]
      end
    end

    # Send the CSV file for download
    send_data csv_data, filename: "clients_export.csv", type: "text/csv"
  end

  def meter_reading_export
    park = Park.find(params[:park_id])
    start_date = params[:start_date]
    end_date = params[:end_date]

    meter_readings = MeterReading.includes(:user, pitch: :park)
                                 .where(pitches: { park_id: park.id })
                                 .where("(start_date BETWEEN ? AND ?) OR (end_date BETWEEN ? AND ?)", start_date, end_date, start_date, end_date)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["User", "Pitch Number", "Park Name", "Utility", "Start Date", "End Date", "Opening Reading", "Ending Reading", "Consumption"]

      meter_readings.find_each do |reading|
        csv << [
          reading.user.full_name,
          reading.pitch.pitch_number,
          reading.pitch.park.name,
          reading.utility,
          reading.start_date,
          reading.end_date,
          reading.opening_reading,
          reading.closing_reading,
          reading.consumption
        ]
      end
    end

    send_data csv_data, filename: "meter_reading_export_#{Date.today}.csv", type: "text/csv"
  end

  def pitch_fees_export
    park = Park.find(params[:park_id])
    year = params[:year]

    # Preload associations to avoid N+1 queries
    pitch_fees = PitchFee.includes(:user, :pitch).where(park_id: park.id, year: year)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["User", "Pitch Number", "Park Name", "Year", "VAT", "Total"]

      pitch_fees.find_each do |fee|
        csv << [
          fee.user.full_name,
          fee.pitch.pitch_number,    # ✅ correct pitch
          fee.pitch.park.name,       # ✅ correct park
          fee.year,
          "#{fee.vat.to_i}%",
          fee.total
        ]
      end
    end

    send_data csv_data,
              filename: "pitch_fees_export_#{Date.today}.csv",
              type: "text/csv",
              disposition: "attachment"
  end
end

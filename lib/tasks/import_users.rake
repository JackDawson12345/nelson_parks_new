# frozen_string_literal: true

require "csv"

namespace :users do
  desc "Import Devise users from CSV. Usage: rails users:import[tmp/import_users.csv]"
  task :import, [:csv_path] => :environment do |_task, args|
    csv_path = args[:csv_path]

    abort "Usage: rails users:import[path/to/users.csv]" if csv_path.blank?
    abort "File not found: #{csv_path}" unless File.exist?(csv_path)

    created = 0
    skipped = 0
    failed = 0

    CSV.foreach(csv_path, headers: true) do |row|

      email = row['email_address']&.strip&.downcase
      password = SecureRandom.hex(16)
      park_name = row['park_name']
      plot_number = row['plot_number']
      first_name = row['first_name']
      last_name = row['last_name']

      if email.blank?
        skipped += 1
        puts "Skipped row: missing email"
        next
      end

      if User.exists?(email: email)
        skipped += 1
        puts "Skipped #{email}: already exists"
        next
      end

      user = User.create(
        email: email,
        password: password.presence || SecureRandom.hex(16),
        password_confirmation: password.presence || SecureRandom.hex(16),
        full_name: first_name + ' ' + last_name,
      )

      if park_name == 'Sycamores'
        Pitch.create(pitch_number: plot_number, park_id: 7, pitch_type: 'Static', status: 'Occupied', user_id: user.id)
      elsif park_name == 'Bell Aire'
        Pitch.create(pitch_number: plot_number, park_id: 6, pitch_type: 'Static', status: 'Occupied', user_id: user.id)
      elsif park_name == 'Florida Keys'
        Pitch.create(pitch_number: plot_number, park_id: 5, pitch_type: 'Static', status: 'Occupied', user_id: user.id)
      end

    end

    puts "\nImport complete"
    puts "Created: #{created}"
    puts "Skipped: #{skipped}"
    puts "Failed: #{failed}"
  end

  desc "Import Devise users from CSV. Usage: rails users:import[tmp/import_users.csv]"
  task :match_xero_id, [:csv_path] => :environment do |_task, args|
    csv_path = args[:csv_path]

    abort "Usage: rails users:import[path/to/users.csv]" if csv_path.blank?
    abort "File not found: #{csv_path}" unless File.exist?(csv_path)

    created = 0
    skipped = 0
    failed = 0

    CSV.foreach(csv_path, headers: true) do |row|
      email = row['email_address']&.strip&.downcase

      next if email.blank?

      user = User.find_by(email: email)
      xero_id = row['user_id']

      user.update(xero_id: xero_id)
      puts user.email + " updated"

    end
  end
end
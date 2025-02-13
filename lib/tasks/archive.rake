# lib/tasks/archive.rake
namespace :archive do
  desc "Archive data older than 1 month and remove them"
  task data: :environment do
    # Define the folder where the SQL dump will be saved
    archive_folder = Rails.root.join("tmp", "sql_archives")
    FileUtils.mkdir_p(archive_folder) unless Dir.exist?(archive_folder)

    # Get the current date in YYYY-MM-DD format for naming the archive file
    current_date = Time.now.strftime("%F")
    dump_file = archive_folder.join("archive_#{current_date}.sql")

    # Define the cutoff date: 1 month ago
    one_month_ago = 1.month.ago

    # Query records with updated_at older than 1 month
    records_to_archive = SleepRecord.where("updated_at < ?", one_month_ago)

    if records_to_archive.exists?
      # Get the database name from Rails configuration
      db_config = Rails.configuration.database_configuration[Rails.env]
      db_name = db_config["database"]

      # Build the mysqldump command to dump only the sleep_records table
      where_clause = "updated_at < '#{one_month_ago.to_formatted_s(:db)}'"
      dump_command = "mysqldump -u root #{db_name} sleep_records --where=\"#{where_clause}\" > #{dump_file}"

      begin
        if system(dump_command)
          puts "Database archived to #{dump_file}"
          # After successful dump, remove the old records
          deleted_count = records_to_archive.delete_all
          puts "Deleted #{deleted_count} sleep records older than 1 month."
        else
          puts "mysqldump command failed."
        end
      rescue => e
        puts "Error during archive: #{e.message}"
      end
    else
      puts "No records older than 1 month to archive."
    end
  end
end

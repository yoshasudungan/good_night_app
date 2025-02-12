class AddSleepTimeToSleepRecords < ActiveRecord::Migration[7.2]
  def change
    add_column :sleep_records, :sleep_days, :integer, default: 0
    add_column :sleep_records, :sleep_hours, :integer, default: 0
    add_column :sleep_records, :sleep_minutes, :integer, default: 0

    reversible do |dir|
      dir.up do
        SleepRecord.reset_column_information
        SleepRecord.find_each do |sleep_record|
          total_minutes = (sleep_record.clock_out - sleep_record.clock_in) / 60
          sleep_record.update(
            sleep_days: (total_minutes / (24 * 60)).to_i,
            sleep_hours: ((total_minutes % (24 * 60)) / 60).to_i,
            sleep_minutes: (total_minutes % 60).to_i
          )
        end
      end
    end
  end
end

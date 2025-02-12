class AddTotalTimeToSleepRecords < ActiveRecord::Migration[7.2]
  def change
    add_column :sleep_records, :total_time, :integer

    reversible do |dir|
      dir.up do
        SleepRecord.reset_column_information
        SleepRecord.find_each do |sleep_record|
          total_minutes = ((sleep_record.clock_out - sleep_record.clock_in)).to_i
          sleep_record.update(total_time: total_minutes)
        end
      end
    end
  end
end
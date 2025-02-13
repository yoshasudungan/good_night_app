class AddCompositeIndexToSleepRecords < ActiveRecord::Migration[7.0]
  def change
    add_index :sleep_records, [:user_id, :updated_at], name: "index_sleep_records_on_user_id_and_updated_at"
  end
end

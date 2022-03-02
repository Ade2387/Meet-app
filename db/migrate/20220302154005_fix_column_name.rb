class FixColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :events, :start_at, :start_time
    rename_column :events, :end_at, :end_time
    rename_column :slots, :start_at, :start_time
    rename_column :slots, :end_at, :end_time
  end
end

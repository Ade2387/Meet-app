class CreateSlots < ActiveRecord::Migration[6.1]
  def change
    create_table :slots do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.string :status
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end

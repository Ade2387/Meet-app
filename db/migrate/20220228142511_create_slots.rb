class CreateSlots < ActiveRecord::Migration[6.1]
  def change
    create_table :slots do |t|
      t.datetime :start
      t.datetime :end
      t.string :status
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
